class FetchMastery
  MASTERY_INTRODUCED_ON = Date.parse('2015-04-28')
  MASTERY_AGE = (Date.today - MASTERY_INTRODUCED_ON).to_i

  RECENCY_DAMPENING = 0.6

  # cutoff should be
  # => ~mastery_age * (avg_mastery / mastery_age / num_champs)
  # => MASTERY_AGE * (1500 / 370 /130) = MASTERY_AGE * 11
  MASTERY_CUTOFF = MASTERY_AGE * 300
  # MASTERY_CUTOFF = MASTERY_AGE * 11
  # MASTERY_CUTOFF = MASTERY_AGE * 200
  MASTERY_DAMPENING = 1.136
  # MASTERY_DAMPENING = 1.33

  def initialize
    @client = RiotClient.new
  end

  def fetch_all
    Summoner.all.each { |s| fetch_mastery(s) }
  end

  def fetch_outdated
    too_old = 3.days.ago
    # too_old = 1.hour.ago
    Summoner.where("last_scraped_at < :too_old", {:too_old => too_old}).each { |s| fetch_mastery(s) }
    Summoner.where(last_scraped_at: nil).each { |s| fetch_mastery(s) }
  end

  def fetch_mastery(summoner)
    mastery_data = @client.champion_mastery.summoner_champions(summoner.region, summoner.id)
    uw_mastery_points = 0
    last_scraped_at = Time.zone.now

    mastery_data.each do |champion_mastery|
      uw_mastery_points += champion_mastery["championPoints"]

      c = ChampionMastery.where(
        summoner_id: summoner.id,
        champion_id: champion_mastery["championId"]
      ).first_or_initialize

      c.uw_champion_points = champion_mastery["championPoints"]
      c.save!
    end

    summoner.update!(
      uw_mastery_points: uw_mastery_points,
      last_scraped_at: last_scraped_at
    )
  end

  def update_champion_points
    # multiplicative factor to account for release date > mastery introduction
    mult_factors = []
    Champion.all.each do |champion|
      if champion.release_date < MASTERY_INTRODUCED_ON
        mult_factor = 1
      else
        days_since_release = (Date.today - champion.release_date.to_date).to_i
        mult_factor = MASTERY_AGE.to_f / days_since_release
        mult_factor = 1 + (mult_factor-1)*RECENCY_DAMPENING
        mult_factors.push([champion.name, mult_factor])
      end

      champion.champion_masteries.update_all(
        "champion_points = uw_champion_points * #{mult_factor}"
      )
    end
    puts mult_factors

    # Champion.where("release_date > :mastery_intro", {:mastery_intro => MASTERY_INTRODUCED_ON}).each do |champion|
    # end

    # dampening to account for mastery levels over 100,000
    md = (1.0/MASTERY_DAMPENING)
    ChampionMastery.where("champion_points > #{MASTERY_CUTOFF}").update_all(
      "champion_points = #{MASTERY_CUTOFF} + (champion_points - #{MASTERY_CUTOFF})^(#{md})"
    )
  end

  def update_mastery_points
    Summoner.connection.update_sql(<<-SQL)
      UPDATE summoners
        SET mastery_points = (
          SELECT sum(cm.champion_points)
          FROM champion_masteries cm
          WHERE cm.summoner_id = summoners.id
        )
    SQL
  end

  def update_devotion
    avg_mastery_points = Summoner.average(:mastery_points).to_i

    ChampionMastery.update_all(
      "devotion = champion_points::float / #{avg_mastery_points}"
    )
  end

  # def update_devotion
  #   Summoner.all.each { |s| update_devotion_s(s) }
  # end

  # def update_devotion_s(s_id)
  #   s_points = Summoner.find(s_id).mastery_points
  #   ChampionMastery.where(summoner_id: s_id).update_all(
  #     "devotion = champion_points::float / #{s_points}"
  #   )
  #   return nil
  # end

  def update_all_mastery_data
    fetch_all
    update_champion_points
    update_mastery_points
    update_devotion
  end

  def update_outdated_mastery_data
    fetch_outdated
    update_champion_points
    update_mastery_points
    update_devotion
  end

  def update_without_fetch
    update_champion_points
    update_mastery_points
    update_devotion
  end
end


# SELECT
#     c.name,
#     sum(cm.devotion * target.devotion) AS rec_value
# FROM champions c
# JOIN champion_masteries cm ON cm.champion_id = c.id
# LEFT JOIN LATERAL (
#     SELECT cm2.devotion FROM champion_masteries cm2 JOIN champions ON champions.id = cm2.champion_id
#         WHERE champions.name = 'Twitch'
#         AND cm2.summoner_id = cm.summoner_id
# ) target ON true
# GROUP BY c.id
# ORDER BY rec_value DESC;
