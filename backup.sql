PGDMP                   
    {            prueba2    16.1    16.1     �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    16414    prueba2    DATABASE     �   CREATE DATABASE prueba2 WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United States.1252';
    DROP DATABASE prueba2;
                postgres    false            �            1259    16418    dos    TABLE        CREATE TABLE public.dos (
);
    DROP TABLE public.dos;
       public         heap    postgres    false            �            1259    16415    una    TABLE        CREATE TABLE public.una (
);
    DROP TABLE public.una;
       public         heap    postgres    false            �          0    16418    dos 
   TABLE DATA              COPY public.dos  FROM stdin;
    public          postgres    false    216   �       �          0    16415    una 
   TABLE DATA              COPY public.una  FROM stdin;
    public          postgres    false    215          �      x������ � �      �      x������ � �     