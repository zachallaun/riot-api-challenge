class Recommendations
    # what we really need is:
    # => a database ChampionRecommendations with a column for champion_in, champion_out, and recommend_val

    def update_all_champions
        Champion.all do |x|
            update_champion(x.id)
        end
    end

    def update_champion(x)
        devotion_x = devotion_hash_x(x)

        for champ in devotion_x.keys
            # ChampionRecommendations.where(
            #     champion_in: x, champion_out: y)
            ChampionRecommendations.set_entry(x, champ, devotion_x[champ])
        end
    end

    def for_champion(x)
        rec_x = Hash.new
        ChampionRecommendations.where(champion_in: x) do |rec_entry|
            rec_x[rec_entry.champion_out] = rec_entry.recommend_val
        end
        return rec_x
    end

    def for_champion_wo_db(x)
        return devotion_hash_x(x)
    end

    def for_champion_print(x)
        print_recommendation_hash(for_champion_wo_db(x), 15)
        return nil
    end

    def for_champion_name_print(x)
        c_id = Champion.where(name: x).first.id
        for_champion_print(c_id)
        return nil
    end

    def print_recommendation_hash(h, top_x)
        printlist = []
        for c_id, rec in h.sort_by {|_key, value| value}.reverse.first(top_x)
            c_name = Champion.where(id: c_id).first.name
            printlist.push([c_name, rec])
        end
        for c_name, rec in printlist
            puts "#{c_name}:\t#{rec}"
        end
        return nil
    end

    # xs is an array of champion_ids, ws is a hash from champion_id to weight
    def for_champions(xs, ws)
        rec = Hash.new(0)
        for x in xs
            rec_x = for_champion(x)
            for y in rec_x.keys
                rec[y] += ws[x] * rec_x[y]
            end
        end
        return rec
    end

    def for_summoner(s_id)
        devotion_s = devotion_hash_s(s_id)
        return for_champions(devotion_s.keys, devotion_s)
    end

    def for_summoner_using_top(s_id, top_x)
        devotion_s = devotion_hash_s(s_id)
        devotion_s_top = devotion_s.sort_by {|_key, value| value}.last(top_x).to_h

        return for_champions(devotion_s_top.keys, devotion_s_top)
    end

    private

    def devotion_hash_s(s_id)
        devotion_s = Hash.new(0)
        ChampionMastery.where(summoner_id: s_id).each do |champ_mastery_x|
            devotion_s[champ_mastery_x.champion_id] = champ_mastery_x.devotion
        end
        return devotion_s
    end

    def devotion_hash_x(c_id)
        devotion_x = Hash.new(0)
        ChampionMastery.where(champion_id: c_id).each do |champ_mastery_x|
            devotion_s = devotion_hash_s(champ_mastery_x.summoner_id)

            s_devotion_for_x = devotion_s[c_id]
            for champ in devotion_s.keys
                devotion_x[champ] += devotion_s[champ] * s_devotion_for_x
            end
        end
        return devotion_x
    end
end
