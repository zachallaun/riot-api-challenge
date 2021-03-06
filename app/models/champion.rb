class Champion < ActiveRecord::Base
  has_many :champion_masteries
  has_many :recommendations, -> { order(score: :desc) }, foreign_key: 'champion_in_id', class_name: 'ChampionRecommendation'

  scope :by_names, -> (names) {
    values = names.map.with_index { |n, i| "(#{ActiveRecord::Base::sanitize(n)}, #{i})" }.join(", ")

    joins(
      "JOIN (VALUES #{values}) names(name, index) ON champions.name ILIKE names.name"
    ).order(
      "names.index ASC"
    )
  }

  def self.recommended_for(champions, summoner=nil)
    if summoner.present?
      champions_in = champions.select(
        "champions.*",
        "coalesce(cm.devotion, 0) AS devotion"
      ).joins(
        "LEFT JOIN champion_masteries cm ON cm.champion_id = champions.id AND cm.summoner_id = #{summoner.id}"
      )
    else
      champions_in = champions.select(
        "champions.*",
        "#{1.0/champions.count} AS devotion"
      )
    end

    Champion.select(
      "champions.*",
      "SUM(recs.score * champions_in.devotion) AS score"
    ).from(
      "(#{champions_in.to_sql}) champions_in, champions JOIN champion_recommendations recs ON recs.champion_out_id = champions.id"
    ).where(
      "champions_in.id = recs.champion_in_id"
    ).where(
      "champions.id NOT IN (#{champions.select(:id).to_sql})"
    ).group(
      "champions.id"
    ).order(
      "SUM(recs.score * champions_in.devotion) DESC"
    )
  end

  def self.from_api(asset_version, api_data)
    champion = where(id: api_data[:id]).first_or_initialize

    name = api_data[:name]

    champion.asset_version = asset_version
    champion.name  = name
    champion.key   = api_data[:key]
    champion.title = api_data[:title]
    champion.image = api_data[:image][:full]
    champion.skins = api_data[:skins]

    champion.release_date = ChampionConstants::CHAMP_RELEASE_DATES[name]
    champion.nickname     = ChampionConstants::CHAMP_NICKNAMES[name]

    champion.spells = ([api_data[:passive]] + api_data[:spells]).map.with_index do |s, i|
      ChampionConstants.spell_info(s, asset_version, passive: i == 0)
    end

    ChampionConstants::ROLE_MAP.each do |key, role|
      champion.send("#{role}=", ChampionConstants::CHAMP_ROLES[name].include?(key))
    end

    champion
  end

  def self.random_splash
    random_champ = Champion.order("RANDOM()").first
    random_skin_num = random_champ.skins.sample["num"]
    random_champ.splash_url(random_skin_num)
  end

  # def self.get_id(name)
  #   return Champion.where(name: name).first.id
  # end

  def self.standardize_name(name)
    name = name.downcase
    ret = []
    for part in name.split(" ")
      ret.push(part.split("'").map(&:capitalize).join("'"))
    end
    return ret.join(" ")
  end

  def self.standardize_name_url(name)
    name = name.gsub('_', ' ')
    return standardize_name(name)
  end

  def image_url
    RiotClient::ASSET_PREFIX + "#{asset_version}/img/champion/#{image}"
  end

  def loading_screen_url
    RiotClient::ASSET_PREFIX + "img/champion/loading/#{key}_0.jpg"
  end

  def splash_url(n = 0)
    RiotClient::ASSET_PREFIX + "img/champion/splash/#{key}_#{n}.jpg"
  end

  def display_title
    nickname || title
  end
end
