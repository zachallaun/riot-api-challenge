--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: champion_masteries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE champion_masteries (
    id integer NOT NULL,
    summoner_id integer,
    champion_id integer,
    uw_champion_points integer,
    champion_points integer,
    devotion double precision
);


--
-- Name: champion_masteries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE champion_masteries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: champion_masteries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE champion_masteries_id_seq OWNED BY champion_masteries.id;


--
-- Name: champion_recommendations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE champion_recommendations (
    id integer NOT NULL,
    champion_in_id integer,
    champion_out_id integer,
    score double precision
);


--
-- Name: champion_recommendations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE champion_recommendations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: champion_recommendations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE champion_recommendations_id_seq OWNED BY champion_recommendations.id;


--
-- Name: champions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE champions (
    id integer NOT NULL,
    name character varying NOT NULL,
    key character varying NOT NULL,
    title character varying NOT NULL,
    image character varying NOT NULL,
    asset_version character varying,
    nickname character varying,
    release_date timestamp without time zone,
    can_top boolean DEFAULT false,
    can_jungle boolean DEFAULT false,
    can_mid boolean DEFAULT false,
    can_bot_carry boolean DEFAULT false,
    can_bot_support boolean DEFAULT false,
    skins jsonb,
    spells jsonb
);


--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE delayed_jobs (
    id integer NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    handler text NOT NULL,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying,
    queue character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: summoners; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE summoners (
    id bigint NOT NULL,
    standardized_name character varying NOT NULL,
    display_name character varying NOT NULL,
    summoner_level integer,
    tier integer,
    division integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    profile_icon_id integer,
    last_scraped_at timestamp without time zone,
    uw_mastery_points integer,
    region integer,
    mastery_points integer
);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY champion_masteries ALTER COLUMN id SET DEFAULT nextval('champion_masteries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY champion_recommendations ALTER COLUMN id SET DEFAULT nextval('champion_recommendations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: champion_masteries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY champion_masteries
    ADD CONSTRAINT champion_masteries_pkey PRIMARY KEY (id);


--
-- Name: champion_recommendations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY champion_recommendations
    ADD CONSTRAINT champion_recommendations_pkey PRIMARY KEY (id);


--
-- Name: champions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY champions
    ADD CONSTRAINT champions_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: summoners_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY summoners
    ADD CONSTRAINT summoners_pkey PRIMARY KEY (id);


--
-- Name: unique_summoner_champion_pair; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY champion_masteries
    ADD CONSTRAINT unique_summoner_champion_pair UNIQUE (summoner_id, champion_id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX delayed_jobs_priority ON delayed_jobs USING btree (priority, run_at);


--
-- Name: index_champion_masteries_on_champion_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_champion_masteries_on_champion_id ON champion_masteries USING btree (champion_id);


--
-- Name: index_champion_masteries_on_summoner_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_champion_masteries_on_summoner_id ON champion_masteries USING btree (summoner_id);


--
-- Name: index_champion_recommendations_on_champion_in_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_champion_recommendations_on_champion_in_id ON champion_recommendations USING btree (champion_in_id);


--
-- Name: index_champion_recommendations_on_champion_out_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_champion_recommendations_on_champion_out_id ON champion_recommendations USING btree (champion_out_id);


--
-- Name: index_champions_on_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_champions_on_id ON champions USING btree (id);


--
-- Name: index_champions_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_champions_on_name ON champions USING btree (name);


--
-- Name: index_summoners_on_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_summoners_on_id ON summoners USING btree (id);


--
-- Name: index_summoners_on_standardized_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_summoners_on_standardized_name ON summoners USING btree (standardized_name);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: fk_rails_516c9ad6b1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY champion_recommendations
    ADD CONSTRAINT fk_rails_516c9ad6b1 FOREIGN KEY (champion_out_id) REFERENCES champions(id);


--
-- Name: fk_rails_620c5d91ce; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY champion_masteries
    ADD CONSTRAINT fk_rails_620c5d91ce FOREIGN KEY (champion_id) REFERENCES champions(id);


--
-- Name: fk_rails_b432b13266; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY champion_masteries
    ADD CONSTRAINT fk_rails_b432b13266 FOREIGN KEY (summoner_id) REFERENCES summoners(id);


--
-- Name: fk_rails_b7c6bb49e6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY champion_recommendations
    ADD CONSTRAINT fk_rails_b7c6bb49e6 FOREIGN KEY (champion_in_id) REFERENCES champions(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20160430183134');

INSERT INTO schema_migrations (version) VALUES ('20160430204636');

INSERT INTO schema_migrations (version) VALUES ('20160430213310');

INSERT INTO schema_migrations (version) VALUES ('20160430213954');

INSERT INTO schema_migrations (version) VALUES ('20160501040938');

INSERT INTO schema_migrations (version) VALUES ('20160501153855');

INSERT INTO schema_migrations (version) VALUES ('20160501162319');

INSERT INTO schema_migrations (version) VALUES ('20160501170204');

INSERT INTO schema_migrations (version) VALUES ('20160501173906');

INSERT INTO schema_migrations (version) VALUES ('20160501232018');

INSERT INTO schema_migrations (version) VALUES ('20160502010742');

INSERT INTO schema_migrations (version) VALUES ('20160503005452');

INSERT INTO schema_migrations (version) VALUES ('20160503010211');

INSERT INTO schema_migrations (version) VALUES ('20160503011152');

INSERT INTO schema_migrations (version) VALUES ('20160504022331');

INSERT INTO schema_migrations (version) VALUES ('20160505191858');

INSERT INTO schema_migrations (version) VALUES ('20160506194628');

