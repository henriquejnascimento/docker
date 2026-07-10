--
-- PostgreSQL database dump
--

\restrict iiYa8tX98ysJ6zToJNXZ6ay55bKg5H3U1oppSUZKTKgNOoMh3Tu5NkStBVzAvn4

-- Dumped from database version 17.5 (Debian 17.5-1.pgdg120+1)
-- Dumped by pg_dump version 17.10 (Ubuntu 17.10-1.pgdg22.04+1)

-- Started on 2026-07-09 20:03:53 -03

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 3374 (class 1262 OID 57366)
-- Name: financial_market; Type: DATABASE; Schema: -; Owner: postgres
--


--CREATE DATABASE financial_market WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


ALTER DATABASE financial_market OWNER TO postgres;

\unrestrict iiYa8tX98ysJ6zToJNXZ6ay55bKg5H3U1oppSUZKTKgNOoMh3Tu5NkStBVzAvn4
\connect financial_market
\restrict iiYa8tX98ysJ6zToJNXZ6ay55bKg5H3U1oppSUZKTKgNOoMh3Tu5NkStBVzAvn4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 57388)
-- Name: asset; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.asset (
    id integer NOT NULL,
    id_portfolio integer NOT NULL,
    code character varying(255),
    name character varying(255),
    is_active boolean DEFAULT true
);


ALTER TABLE public.asset OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 57387)
-- Name: asset_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.asset ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.asset_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 218 (class 1259 OID 57377)
-- Name: portfolio; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.portfolio (
    id integer NOT NULL,
    name character varying(255)
);


ALTER TABLE public.portfolio OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 57376)
-- Name: portfolio_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.portfolio ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.portfolio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 3368 (class 0 OID 57388)
-- Dependencies: 220
-- Data for Name: asset; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.asset OVERRIDING SYSTEM VALUE VALUES (1, 1, 'VALE3', 'VALE', true);
INSERT INTO public.asset OVERRIDING SYSTEM VALUE VALUES (2, 1, 'PETR3', 'Petrobras', true);
INSERT INTO public.asset OVERRIDING SYSTEM VALUE VALUES (3, 1, 'BRKM5', 'Braskem', true);


--
-- TOC entry 3366 (class 0 OID 57377)
-- Dependencies: 218
-- Data for Name: portfolio; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.portfolio OVERRIDING SYSTEM VALUE VALUES (1, 'Asset 1');


--
-- TOC entry 3375 (class 0 OID 0)
-- Dependencies: 219
-- Name: asset_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.asset_id_seq', 3, true);


--
-- TOC entry 3376 (class 0 OID 0)
-- Dependencies: 217
-- Name: portfolio_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.portfolio_id_seq', 1, true);


--
-- TOC entry 3219 (class 2606 OID 57395)
-- Name: asset asset_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.asset
    ADD CONSTRAINT asset_pkey PRIMARY KEY (id);


--
-- TOC entry 3217 (class 2606 OID 57381)
-- Name: portfolio portfolio_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.portfolio
    ADD CONSTRAINT portfolio_pkey PRIMARY KEY (id);


-- Completed on 2026-07-09 20:03:53 -03

--
-- PostgreSQL database dump complete
--

\unrestrict iiYa8tX98ysJ6zToJNXZ6ay55bKg5H3U1oppSUZKTKgNOoMh3Tu5NkStBVzAvn4

