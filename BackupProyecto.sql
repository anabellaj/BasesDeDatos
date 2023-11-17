PGDMP          	        
    {            Proyecto BDD    16.0    16.0 |    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    16398    Proyecto BDD    DATABASE     p   CREATE DATABASE "Proyecto BDD" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'C';
    DROP DATABASE "Proyecto BDD";
                postgres    false            l           1247    16460    Genero    DOMAIN     �   CREATE DOMAIN public."Genero" AS text
	CONSTRAINT check_domain CHECK ((VALUE = ANY (ARRAY['Pop'::text, 'Rock'::text, 'Balada'::text, 'Electronica'::text, 'Punk'::text, 'Otro'::text])));
    DROP DOMAIN public."Genero";
       public          postgres    false            h           1247    16457    Tematica    DOMAIN     �   CREATE DOMAIN public."Tematica" AS text
	CONSTRAINT check_domain CHECK ((VALUE = ANY (ARRAY['juegos'::text, 'cocina'::text, 'lectura'::text, 'otro'::text])));
    DROP DOMAIN public."Tematica";
       public          postgres    false            y           1247    16512    Tipo_Proveedor    DOMAIN     �   CREATE DOMAIN public."Tipo_Proveedor" AS text
	CONSTRAINT check_domain CHECK ((VALUE = ANY (ARRAY['Desarrollador'::text, 'Empresa'::text])));
 %   DROP DOMAIN public."Tipo_Proveedor";
       public          postgres    false            �            1259    16557 
   Aplicacion    TABLE     �  CREATE TABLE public."Aplicacion" (
    id_producto bigint NOT NULL,
    tamano_mb smallint NOT NULL,
    version text NOT NULL,
    nombre_aplicacion text NOT NULL,
    descripcion text,
    version_ios text NOT NULL,
    tematica public."Tematica" NOT NULL,
    id_proveedor bigint NOT NULL,
    CONSTRAINT check_tamano CHECK ((tamano_mb > 0)),
    CONSTRAINT check_version CHECK ((version ~ '^[1-9.][0-9.]+$'::text)),
    CONSTRAINT check_version_ios CHECK ((version_ios ~ '^[1-9.][0-9.]+$'::text))
);
     DROP TABLE public."Aplicacion";
       public         heap    postgres    false    872            �            1259    16555    Aplicacion_id_producto_seq    SEQUENCE     �   CREATE SEQUENCE public."Aplicacion_id_producto_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public."Aplicacion_id_producto_seq";
       public          postgres    false    232            �           0    0    Aplicacion_id_producto_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public."Aplicacion_id_producto_seq" OWNED BY public."Aplicacion".id_producto;
          public          postgres    false    230            �            1259    16556    Aplicacion_id_proveedor_seq    SEQUENCE     �   CREATE SEQUENCE public."Aplicacion_id_proveedor_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public."Aplicacion_id_proveedor_seq";
       public          postgres    false    232            �           0    0    Aplicacion_id_proveedor_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public."Aplicacion_id_proveedor_seq" OWNED BY public."Aplicacion".id_proveedor;
          public          postgres    false    231            �            1259    16473    Artista    TABLE       CREATE TABLE public."Artista" (
    id_artista bigint NOT NULL,
    nom_artistico text NOT NULL,
    nombre_casa text DEFAULT 'Independiente'::text,
    fecha_inicio date,
    fecha_fin date,
    CONSTRAINT check_fecha CHECK ((fecha_inicio < fecha_fin))
);
    DROP TABLE public."Artista";
       public         heap    postgres    false            �            1259    16472    Artista_id_artista_seq    SEQUENCE     �   CREATE SEQUENCE public."Artista_id_artista_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public."Artista_id_artista_seq";
       public          postgres    false    219            �           0    0    Artista_id_artista_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public."Artista_id_artista_seq" OWNED BY public."Artista".id_artista;
          public          postgres    false    218            �            1259    16611    Cancion    TABLE     1  CREATE TABLE public."Cancion" (
    id_producto bigint NOT NULL,
    nom_cancion text NOT NULL,
    fecha_lanz date NOT NULL,
    duracion_cancion smallint NOT NULL,
    genero public."Genero" NOT NULL,
    unidades_vendidas bigint NOT NULL,
    nom_disco text NOT NULL,
    id_artista bigint NOT NULL
);
    DROP TABLE public."Cancion";
       public         heap    postgres    false    876            �            1259    16610    Cancion_id_artista_seq    SEQUENCE     �   CREATE SEQUENCE public."Cancion_id_artista_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public."Cancion_id_artista_seq";
       public          postgres    false    237            �           0    0    Cancion_id_artista_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public."Cancion_id_artista_seq" OWNED BY public."Cancion".id_artista;
          public          postgres    false    236            �            1259    16609    Cancion_id_producto_seq    SEQUENCE     �   CREATE SEQUENCE public."Cancion_id_producto_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public."Cancion_id_producto_seq";
       public          postgres    false    237            �           0    0    Cancion_id_producto_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public."Cancion_id_producto_seq" OWNED BY public."Cancion".id_producto;
          public          postgres    false    235            �            1259    16399    Casa_Disquera    TABLE     `   CREATE TABLE public."Casa_Disquera" (
    nombre_casa text NOT NULL,
    direccion_casa text
);
 #   DROP TABLE public."Casa_Disquera";
       public         heap    postgres    false            �            1259    16657    Compra    TABLE     �   CREATE TABLE public."Compra" (
    id_usuario bigint NOT NULL,
    id_producto bigint NOT NULL,
    id_promo bigint NOT NULL,
    fecha_compra date NOT NULL,
    rating smallint NOT NULL,
    monto smallint NOT NULL
);
    DROP TABLE public."Compra";
       public         heap    postgres    false            �            1259    16655    Compra_id_producto_seq    SEQUENCE     �   CREATE SEQUENCE public."Compra_id_producto_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public."Compra_id_producto_seq";
       public          postgres    false    241            �           0    0    Compra_id_producto_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public."Compra_id_producto_seq" OWNED BY public."Compra".id_producto;
          public          postgres    false    239            �            1259    16656    Compra_id_promo_seq    SEQUENCE     ~   CREATE SEQUENCE public."Compra_id_promo_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public."Compra_id_promo_seq";
       public          postgres    false    241            �           0    0    Compra_id_promo_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public."Compra_id_promo_seq" OWNED BY public."Compra".id_promo;
          public          postgres    false    240            �            1259    16654    Compra_id_usuario_seq    SEQUENCE     �   CREATE SEQUENCE public."Compra_id_usuario_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public."Compra_id_usuario_seq";
       public          postgres    false    241            �           0    0    Compra_id_usuario_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public."Compra_id_usuario_seq" OWNED BY public."Compra".id_usuario;
          public          postgres    false    238            �            1259    16544    Dispositivo    TABLE     �  CREATE TABLE public."Dispositivo" (
    id_producto bigint NOT NULL,
    modelo text NOT NULL,
    generacion smallint NOT NULL,
    version_ios text NOT NULL,
    capacidad smallint NOT NULL,
    CONSTRAINT check_capacidadad CHECK ((capacidad > 0)),
    CONSTRAINT check_generacion CHECK ((generacion > 0)),
    CONSTRAINT check_version_ios CHECK ((version_ios ~ '^[1-9.][0-9.]+$'::text))
);
 !   DROP TABLE public."Dispositivo";
       public         heap    postgres    false            �            1259    16596    Dispositivo_Aplicacion    TABLE     |   CREATE TABLE public."Dispositivo_Aplicacion" (
    id_producto bigint NOT NULL,
    dispositivo_compatible text NOT NULL
);
 ,   DROP TABLE public."Dispositivo_Aplicacion";
       public         heap    postgres    false            �            1259    16595 &   Dispositivo_Aplicacion_id_producto_seq    SEQUENCE     �   CREATE SEQUENCE public."Dispositivo_Aplicacion_id_producto_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ?   DROP SEQUENCE public."Dispositivo_Aplicacion_id_producto_seq";
       public          postgres    false    234            �           0    0 &   Dispositivo_Aplicacion_id_producto_seq    SEQUENCE OWNED BY     u   ALTER SEQUENCE public."Dispositivo_Aplicacion_id_producto_seq" OWNED BY public."Dispositivo_Aplicacion".id_producto;
          public          postgres    false    233            �            1259    16543    Dispositivo_id_producto_seq    SEQUENCE     �   CREATE SEQUENCE public."Dispositivo_id_producto_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public."Dispositivo_id_producto_seq";
       public          postgres    false    229            �           0    0    Dispositivo_id_producto_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public."Dispositivo_id_producto_seq" OWNED BY public."Dispositivo".id_producto;
          public          postgres    false    228            �            1259    16498    Paises_Promo    TABLE     ]   CREATE TABLE public."Paises_Promo" (
    id_promo bigint NOT NULL,
    pais text NOT NULL
);
 "   DROP TABLE public."Paises_Promo";
       public         heap    postgres    false            �            1259    16497    Paises_Promo_id_promo_seq    SEQUENCE     �   CREATE SEQUENCE public."Paises_Promo_id_promo_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public."Paises_Promo_id_promo_seq";
       public          postgres    false    223            �           0    0    Paises_Promo_id_promo_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public."Paises_Promo_id_promo_seq" OWNED BY public."Paises_Promo".id_promo;
          public          postgres    false    222            �            1259    16534    Producto    TABLE     ;  CREATE TABLE public."Producto" (
    id_producto bigint NOT NULL,
    costo real NOT NULL,
    puntuacion real DEFAULT 0,
    CONSTRAINT check_costo CHECK ((costo > (0)::double precision)),
    CONSTRAINT check_puntuacion CHECK (((puntuacion >= (0)::double precision) AND (puntuacion <= (5)::double precision)))
);
    DROP TABLE public."Producto";
       public         heap    postgres    false            �            1259    16533    Producto_id_producto_seq    SEQUENCE     �   CREATE SEQUENCE public."Producto_id_producto_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public."Producto_id_producto_seq";
       public          postgres    false    227            �           0    0    Producto_id_producto_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public."Producto_id_producto_seq" OWNED BY public."Producto".id_producto;
          public          postgres    false    226            �            1259    16489 	   Promocion    TABLE     �  CREATE TABLE public."Promocion" (
    id_promo bigint NOT NULL,
    fecha_inicio date NOT NULL,
    fecha_fin date NOT NULL,
    duracion_promocion smallint NOT NULL,
    descuento real NOT NULL,
    CONSTRAINT check_descuento CHECK (((descuento >= (0)::double precision) AND (descuento <= (100)::double precision))),
    CONSTRAINT check_fecha CHECK ((fecha_fin >= fecha_inicio))
);
    DROP TABLE public."Promocion";
       public         heap    postgres    false            �            1259    16488    Promocion_id_promo_seq    SEQUENCE     �   CREATE SEQUENCE public."Promocion_id_promo_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public."Promocion_id_promo_seq";
       public          postgres    false    221            �           0    0    Promocion_id_promo_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public."Promocion_id_promo_seq" OWNED BY public."Promocion".id_promo;
          public          postgres    false    220            �            1259    16520 	   Proveedor    TABLE     �  CREATE TABLE public."Proveedor" (
    id_proveedor bigint NOT NULL,
    nombre_proveedor text NOT NULL,
    correo_proveedor text NOT NULL,
    direccion_proveedor text DEFAULT 'N/A'::text,
    fecha_afiliacion date NOT NULL,
    tipo_proveedor public."Tipo_Proveedor" NOT NULL,
    CONSTRAINT check_correo CHECK ((correo_proveedor ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'::text)),
    CONSTRAINT check_fecha CHECK ((fecha_afiliacion <= CURRENT_DATE))
);
    DROP TABLE public."Proveedor";
       public         heap    postgres    false    889            �            1259    16519    Proveedor_id_proveedor_seq    SEQUENCE     �   CREATE SEQUENCE public."Proveedor_id_proveedor_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public."Proveedor_id_proveedor_seq";
       public          postgres    false    225            �           0    0    Proveedor_id_proveedor_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public."Proveedor_id_proveedor_seq" OWNED BY public."Proveedor".id_proveedor;
          public          postgres    false    224            �            1259    16431    Usuario    TABLE     =  CREATE TABLE public."Usuario" (
    id_usuario bigint NOT NULL,
    nombre_usuario text NOT NULL,
    apellido_usuario text NOT NULL,
    correo_usuario text NOT NULL,
    ciudad_usuario text,
    pais_usuario text NOT NULL,
    fecha_venc date NOT NULL,
    num_tdc bigint NOT NULL,
    cod_vvt smallint NOT NULL
);
    DROP TABLE public."Usuario";
       public         heap    postgres    false            �            1259    16430    Usuario_id_usuario_seq    SEQUENCE     �   CREATE SEQUENCE public."Usuario_id_usuario_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public."Usuario_id_usuario_seq";
       public          postgres    false    217            �           0    0    Usuario_id_usuario_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public."Usuario_id_usuario_seq" OWNED BY public."Usuario".id_usuario;
          public          postgres    false    216            �           2604    16560    Aplicacion id_producto    DEFAULT     �   ALTER TABLE ONLY public."Aplicacion" ALTER COLUMN id_producto SET DEFAULT nextval('public."Aplicacion_id_producto_seq"'::regclass);
 G   ALTER TABLE public."Aplicacion" ALTER COLUMN id_producto DROP DEFAULT;
       public          postgres    false    230    232    232            �           2604    16561    Aplicacion id_proveedor    DEFAULT     �   ALTER TABLE ONLY public."Aplicacion" ALTER COLUMN id_proveedor SET DEFAULT nextval('public."Aplicacion_id_proveedor_seq"'::regclass);
 H   ALTER TABLE public."Aplicacion" ALTER COLUMN id_proveedor DROP DEFAULT;
       public          postgres    false    232    231    232            �           2604    16476    Artista id_artista    DEFAULT     |   ALTER TABLE ONLY public."Artista" ALTER COLUMN id_artista SET DEFAULT nextval('public."Artista_id_artista_seq"'::regclass);
 C   ALTER TABLE public."Artista" ALTER COLUMN id_artista DROP DEFAULT;
       public          postgres    false    218    219    219            �           2604    16614    Cancion id_producto    DEFAULT     ~   ALTER TABLE ONLY public."Cancion" ALTER COLUMN id_producto SET DEFAULT nextval('public."Cancion_id_producto_seq"'::regclass);
 D   ALTER TABLE public."Cancion" ALTER COLUMN id_producto DROP DEFAULT;
       public          postgres    false    235    237    237            �           2604    16615    Cancion id_artista    DEFAULT     |   ALTER TABLE ONLY public."Cancion" ALTER COLUMN id_artista SET DEFAULT nextval('public."Cancion_id_artista_seq"'::regclass);
 C   ALTER TABLE public."Cancion" ALTER COLUMN id_artista DROP DEFAULT;
       public          postgres    false    237    236    237            �           2604    16660    Compra id_usuario    DEFAULT     z   ALTER TABLE ONLY public."Compra" ALTER COLUMN id_usuario SET DEFAULT nextval('public."Compra_id_usuario_seq"'::regclass);
 B   ALTER TABLE public."Compra" ALTER COLUMN id_usuario DROP DEFAULT;
       public          postgres    false    238    241    241            �           2604    16661    Compra id_producto    DEFAULT     |   ALTER TABLE ONLY public."Compra" ALTER COLUMN id_producto SET DEFAULT nextval('public."Compra_id_producto_seq"'::regclass);
 C   ALTER TABLE public."Compra" ALTER COLUMN id_producto DROP DEFAULT;
       public          postgres    false    241    239    241            �           2604    16662    Compra id_promo    DEFAULT     v   ALTER TABLE ONLY public."Compra" ALTER COLUMN id_promo SET DEFAULT nextval('public."Compra_id_promo_seq"'::regclass);
 @   ALTER TABLE public."Compra" ALTER COLUMN id_promo DROP DEFAULT;
       public          postgres    false    241    240    241            �           2604    16547    Dispositivo id_producto    DEFAULT     �   ALTER TABLE ONLY public."Dispositivo" ALTER COLUMN id_producto SET DEFAULT nextval('public."Dispositivo_id_producto_seq"'::regclass);
 H   ALTER TABLE public."Dispositivo" ALTER COLUMN id_producto DROP DEFAULT;
       public          postgres    false    228    229    229            �           2604    16599 "   Dispositivo_Aplicacion id_producto    DEFAULT     �   ALTER TABLE ONLY public."Dispositivo_Aplicacion" ALTER COLUMN id_producto SET DEFAULT nextval('public."Dispositivo_Aplicacion_id_producto_seq"'::regclass);
 S   ALTER TABLE public."Dispositivo_Aplicacion" ALTER COLUMN id_producto DROP DEFAULT;
       public          postgres    false    233    234    234            �           2604    16501    Paises_Promo id_promo    DEFAULT     �   ALTER TABLE ONLY public."Paises_Promo" ALTER COLUMN id_promo SET DEFAULT nextval('public."Paises_Promo_id_promo_seq"'::regclass);
 F   ALTER TABLE public."Paises_Promo" ALTER COLUMN id_promo DROP DEFAULT;
       public          postgres    false    222    223    223            �           2604    16537    Producto id_producto    DEFAULT     �   ALTER TABLE ONLY public."Producto" ALTER COLUMN id_producto SET DEFAULT nextval('public."Producto_id_producto_seq"'::regclass);
 E   ALTER TABLE public."Producto" ALTER COLUMN id_producto DROP DEFAULT;
       public          postgres    false    226    227    227            �           2604    16492    Promocion id_promo    DEFAULT     |   ALTER TABLE ONLY public."Promocion" ALTER COLUMN id_promo SET DEFAULT nextval('public."Promocion_id_promo_seq"'::regclass);
 C   ALTER TABLE public."Promocion" ALTER COLUMN id_promo DROP DEFAULT;
       public          postgres    false    220    221    221            �           2604    16523    Proveedor id_proveedor    DEFAULT     �   ALTER TABLE ONLY public."Proveedor" ALTER COLUMN id_proveedor SET DEFAULT nextval('public."Proveedor_id_proveedor_seq"'::regclass);
 G   ALTER TABLE public."Proveedor" ALTER COLUMN id_proveedor DROP DEFAULT;
       public          postgres    false    224    225    225            �           2604    16434    Usuario id_usuario    DEFAULT     |   ALTER TABLE ONLY public."Usuario" ALTER COLUMN id_usuario SET DEFAULT nextval('public."Usuario_id_usuario_seq"'::regclass);
 C   ALTER TABLE public."Usuario" ALTER COLUMN id_usuario DROP DEFAULT;
       public          postgres    false    216    217    217            �          0    16557 
   Aplicacion 
   TABLE DATA           �   COPY public."Aplicacion" (id_producto, tamano_mb, version, nombre_aplicacion, descripcion, version_ios, tematica, id_proveedor) FROM stdin;
    public          postgres    false    232   �       �          0    16473    Artista 
   TABLE DATA           d   COPY public."Artista" (id_artista, nom_artistico, nombre_casa, fecha_inicio, fecha_fin) FROM stdin;
    public          postgres    false    219   �       �          0    16611    Cancion 
   TABLE DATA           �   COPY public."Cancion" (id_producto, nom_cancion, fecha_lanz, duracion_cancion, genero, unidades_vendidas, nom_disco, id_artista) FROM stdin;
    public          postgres    false    237   "�       �          0    16399    Casa_Disquera 
   TABLE DATA           F   COPY public."Casa_Disquera" (nombre_casa, direccion_casa) FROM stdin;
    public          postgres    false    215   ?�       �          0    16657    Compra 
   TABLE DATA           b   COPY public."Compra" (id_usuario, id_producto, id_promo, fecha_compra, rating, monto) FROM stdin;
    public          postgres    false    241   \�       �          0    16544    Dispositivo 
   TABLE DATA           `   COPY public."Dispositivo" (id_producto, modelo, generacion, version_ios, capacidad) FROM stdin;
    public          postgres    false    229   y�       �          0    16596    Dispositivo_Aplicacion 
   TABLE DATA           W   COPY public."Dispositivo_Aplicacion" (id_producto, dispositivo_compatible) FROM stdin;
    public          postgres    false    234   ��       �          0    16498    Paises_Promo 
   TABLE DATA           8   COPY public."Paises_Promo" (id_promo, pais) FROM stdin;
    public          postgres    false    223   ��       �          0    16534    Producto 
   TABLE DATA           D   COPY public."Producto" (id_producto, costo, puntuacion) FROM stdin;
    public          postgres    false    227   О       �          0    16489 	   Promocion 
   TABLE DATA           g   COPY public."Promocion" (id_promo, fecha_inicio, fecha_fin, duracion_promocion, descuento) FROM stdin;
    public          postgres    false    221   �       �          0    16520 	   Proveedor 
   TABLE DATA           �   COPY public."Proveedor" (id_proveedor, nombre_proveedor, correo_proveedor, direccion_proveedor, fecha_afiliacion, tipo_proveedor) FROM stdin;
    public          postgres    false    225   
�       �          0    16431    Usuario 
   TABLE DATA           �   COPY public."Usuario" (id_usuario, nombre_usuario, apellido_usuario, correo_usuario, ciudad_usuario, pais_usuario, fecha_venc, num_tdc, cod_vvt) FROM stdin;
    public          postgres    false    217   '�       �           0    0    Aplicacion_id_producto_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public."Aplicacion_id_producto_seq"', 1, false);
          public          postgres    false    230            �           0    0    Aplicacion_id_proveedor_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public."Aplicacion_id_proveedor_seq"', 1, false);
          public          postgres    false    231            �           0    0    Artista_id_artista_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public."Artista_id_artista_seq"', 1, false);
          public          postgres    false    218            �           0    0    Cancion_id_artista_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public."Cancion_id_artista_seq"', 1, false);
          public          postgres    false    236            �           0    0    Cancion_id_producto_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public."Cancion_id_producto_seq"', 1, false);
          public          postgres    false    235            �           0    0    Compra_id_producto_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public."Compra_id_producto_seq"', 1, false);
          public          postgres    false    239            �           0    0    Compra_id_promo_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public."Compra_id_promo_seq"', 1, false);
          public          postgres    false    240            �           0    0    Compra_id_usuario_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public."Compra_id_usuario_seq"', 1, false);
          public          postgres    false    238            �           0    0 &   Dispositivo_Aplicacion_id_producto_seq    SEQUENCE SET     W   SELECT pg_catalog.setval('public."Dispositivo_Aplicacion_id_producto_seq"', 1, false);
          public          postgres    false    233            �           0    0    Dispositivo_id_producto_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public."Dispositivo_id_producto_seq"', 1, false);
          public          postgres    false    228            �           0    0    Paises_Promo_id_promo_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public."Paises_Promo_id_promo_seq"', 1, false);
          public          postgres    false    222            �           0    0    Producto_id_producto_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public."Producto_id_producto_seq"', 1, false);
          public          postgres    false    226            �           0    0    Promocion_id_promo_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public."Promocion_id_promo_seq"', 1, false);
          public          postgres    false    220            �           0    0    Proveedor_id_proveedor_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public."Proveedor_id_proveedor_seq"', 1, false);
          public          postgres    false    224            �           0    0    Usuario_id_usuario_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public."Usuario_id_usuario_seq"', 1, false);
          public          postgres    false    216            �           2606    16568    Aplicacion Aplicacion_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public."Aplicacion"
    ADD CONSTRAINT "Aplicacion_pkey" PRIMARY KEY (id_producto);
 H   ALTER TABLE ONLY public."Aplicacion" DROP CONSTRAINT "Aplicacion_pkey";
       public            postgres    false    232            �           2606    16482    Artista Artista_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public."Artista"
    ADD CONSTRAINT "Artista_pkey" PRIMARY KEY (id_artista);
 B   ALTER TABLE ONLY public."Artista" DROP CONSTRAINT "Artista_pkey";
       public            postgres    false    219            �           2606    16619    Cancion Cancion_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public."Cancion"
    ADD CONSTRAINT "Cancion_pkey" PRIMARY KEY (id_producto);
 B   ALTER TABLE ONLY public."Cancion" DROP CONSTRAINT "Cancion_pkey";
       public            postgres    false    237            �           2606    16405     Casa_Disquera Casa_Disquera_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY public."Casa_Disquera"
    ADD CONSTRAINT "Casa_Disquera_pkey" PRIMARY KEY (nombre_casa);
 N   ALTER TABLE ONLY public."Casa_Disquera" DROP CONSTRAINT "Casa_Disquera_pkey";
       public            postgres    false    215            �           2606    16665    Compra Compra_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public."Compra"
    ADD CONSTRAINT "Compra_pkey" PRIMARY KEY (id_usuario, id_producto, id_promo, fecha_compra);
 @   ALTER TABLE ONLY public."Compra" DROP CONSTRAINT "Compra_pkey";
       public            postgres    false    241    241    241    241            �           2606    16603 2   Dispositivo_Aplicacion Dispositivo_Aplicacion_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public."Dispositivo_Aplicacion"
    ADD CONSTRAINT "Dispositivo_Aplicacion_pkey" PRIMARY KEY (id_producto, dispositivo_compatible);
 `   ALTER TABLE ONLY public."Dispositivo_Aplicacion" DROP CONSTRAINT "Dispositivo_Aplicacion_pkey";
       public            postgres    false    234    234            �           2606    16554    Dispositivo Dispositivo_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY public."Dispositivo"
    ADD CONSTRAINT "Dispositivo_pkey" PRIMARY KEY (id_producto);
 J   ALTER TABLE ONLY public."Dispositivo" DROP CONSTRAINT "Dispositivo_pkey";
       public            postgres    false    229            �           2606    16505    Paises_Promo Paises_Promo_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public."Paises_Promo"
    ADD CONSTRAINT "Paises_Promo_pkey" PRIMARY KEY (id_promo, pais);
 L   ALTER TABLE ONLY public."Paises_Promo" DROP CONSTRAINT "Paises_Promo_pkey";
       public            postgres    false    223    223            �           2606    16542    Producto Producto_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public."Producto"
    ADD CONSTRAINT "Producto_pkey" PRIMARY KEY (id_producto);
 D   ALTER TABLE ONLY public."Producto" DROP CONSTRAINT "Producto_pkey";
       public            postgres    false    227            �           2606    16496    Promocion Promocion_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public."Promocion"
    ADD CONSTRAINT "Promocion_pkey" PRIMARY KEY (id_promo);
 F   ALTER TABLE ONLY public."Promocion" DROP CONSTRAINT "Promocion_pkey";
       public            postgres    false    221            �           2606    16530    Proveedor Proveedor_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public."Proveedor"
    ADD CONSTRAINT "Proveedor_pkey" PRIMARY KEY (id_proveedor);
 F   ALTER TABLE ONLY public."Proveedor" DROP CONSTRAINT "Proveedor_pkey";
       public            postgres    false    225            �           2606    16438    Usuario Usuario_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public."Usuario"
    ADD CONSTRAINT "Usuario_pkey" PRIMARY KEY (id_usuario);
 B   ALTER TABLE ONLY public."Usuario" DROP CONSTRAINT "Usuario_pkey";
       public            postgres    false    217            �           2606    16445    Usuario check_cod_vvt    CHECK CONSTRAINT     z   ALTER TABLE public."Usuario"
    ADD CONSTRAINT check_cod_vvt CHECK (((cod_vvt >= 100) AND (cod_vvt <= 9999))) NOT VALID;
 <   ALTER TABLE public."Usuario" DROP CONSTRAINT check_cod_vvt;
       public          postgres    false    217    217            �           2606    16444    Usuario check_correo_format    CHECK CONSTRAINT     �   ALTER TABLE public."Usuario"
    ADD CONSTRAINT check_correo_format CHECK ((correo_usuario ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'::text)) NOT VALID;
 B   ALTER TABLE public."Usuario" DROP CONSTRAINT check_correo_format;
       public          postgres    false    217    217            �           2606    16443    Usuario check_correo_unico 
   CONSTRAINT     t   ALTER TABLE ONLY public."Usuario"
    ADD CONSTRAINT check_correo_unico UNIQUE NULLS NOT DISTINCT (correo_usuario);
 F   ALTER TABLE ONLY public."Usuario" DROP CONSTRAINT check_correo_unico;
       public            postgres    false    217            �           2606    16532    Proveedor check_correo_unique 
   CONSTRAINT     y   ALTER TABLE ONLY public."Proveedor"
    ADD CONSTRAINT check_correo_unique UNIQUE NULLS NOT DISTINCT (correo_proveedor);
 I   ALTER TABLE ONLY public."Proveedor" DROP CONSTRAINT check_correo_unique;
       public            postgres    false    225            �           2606    16630    Cancion check_duracion    CHECK CONSTRAINT     i   ALTER TABLE public."Cancion"
    ADD CONSTRAINT check_duracion CHECK ((duracion_cancion > 0)) NOT VALID;
 =   ALTER TABLE public."Cancion" DROP CONSTRAINT check_duracion;
       public          postgres    false    237    237            �           2606    16446    Usuario check_fecha    CHECK CONSTRAINT     l   ALTER TABLE public."Usuario"
    ADD CONSTRAINT check_fecha CHECK ((fecha_venc >= CURRENT_DATE)) NOT VALID;
 :   ALTER TABLE public."Usuario" DROP CONSTRAINT check_fecha;
       public          postgres    false    217    217            �           2606    16682    Compra check_fecha    CHECK CONSTRAINT     m   ALTER TABLE public."Compra"
    ADD CONSTRAINT check_fecha CHECK ((fecha_compra <= CURRENT_DATE)) NOT VALID;
 9   ALTER TABLE public."Compra" DROP CONSTRAINT check_fecha;
       public          postgres    false    241    241            �           2606    16447    Usuario check_num_tdc    CHECK CONSTRAINT     �   ALTER TABLE public."Usuario"
    ADD CONSTRAINT check_num_tdc CHECK (((num_tdc >= '100000000000000'::bigint) AND (num_tdc <= '9999999999999999'::bigint))) NOT VALID;
 <   ALTER TABLE public."Usuario" DROP CONSTRAINT check_num_tdc;
       public          postgres    false    217    217            �           2606    16681    Compra check_rating    CHECK CONSTRAINT     q   ALTER TABLE public."Compra"
    ADD CONSTRAINT check_rating CHECK (((rating >= 0) AND (rating <= 5))) NOT VALID;
 :   ALTER TABLE public."Compra" DROP CONSTRAINT check_rating;
       public          postgres    false    241    241            �           2606    16631    Cancion check_unidades    CHECK CONSTRAINT     k   ALTER TABLE public."Cancion"
    ADD CONSTRAINT check_unidades CHECK ((unidades_vendidas >= 0)) NOT VALID;
 =   ALTER TABLE public."Cancion" DROP CONSTRAINT check_unidades;
       public          postgres    false    237    237            �           2606    16590 !   Aplicacion Aplicacion_Producto_FK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Aplicacion"
    ADD CONSTRAINT "Aplicacion_Producto_FK" FOREIGN KEY (id_producto) REFERENCES public."Producto"(id_producto) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 O   ALTER TABLE ONLY public."Aplicacion" DROP CONSTRAINT "Aplicacion_Producto_FK";
       public          postgres    false    227    232    3569                        2606    16574 "   Aplicacion Aplicacion_Proveedor_FK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Aplicacion"
    ADD CONSTRAINT "Aplicacion_Proveedor_FK" FOREIGN KEY (id_proveedor) REFERENCES public."Proveedor"(id_proveedor);
 P   ALTER TABLE ONLY public."Aplicacion" DROP CONSTRAINT "Aplicacion_Proveedor_FK";
       public          postgres    false    232    225    3565            �           2606    16483    Artista Artista_DisqueraFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Artista"
    ADD CONSTRAINT "Artista_DisqueraFK" FOREIGN KEY (nombre_casa) REFERENCES public."Casa_Disquera"(nombre_casa) ON UPDATE CASCADE ON DELETE SET DEFAULT;
 H   ALTER TABLE ONLY public."Artista" DROP CONSTRAINT "Artista_DisqueraFK";
       public          postgres    false    215    3553    219                       2606    16620    Cancion Cancion_ArtistaFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Cancion"
    ADD CONSTRAINT "Cancion_ArtistaFK" FOREIGN KEY (id_artista) REFERENCES public."Artista"(id_artista) ON UPDATE CASCADE;
 G   ALTER TABLE ONLY public."Cancion" DROP CONSTRAINT "Cancion_ArtistaFK";
       public          postgres    false    219    3559    237                       2606    16625    Cancion Cancion_ProductoFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Cancion"
    ADD CONSTRAINT "Cancion_ProductoFK" FOREIGN KEY (id_producto) REFERENCES public."Producto"(id_producto) ON UPDATE CASCADE ON DELETE CASCADE;
 H   ALTER TABLE ONLY public."Cancion" DROP CONSTRAINT "Cancion_ProductoFK";
       public          postgres    false    227    237    3569                       2606    16671    Compra Compra_ProductoFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Compra"
    ADD CONSTRAINT "Compra_ProductoFK" FOREIGN KEY (id_producto) REFERENCES public."Producto"(id_producto) ON UPDATE CASCADE;
 F   ALTER TABLE ONLY public."Compra" DROP CONSTRAINT "Compra_ProductoFK";
       public          postgres    false    227    3569    241                       2606    16676    Compra Compra_PromoFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Compra"
    ADD CONSTRAINT "Compra_PromoFK" FOREIGN KEY (id_promo) REFERENCES public."Promocion"(id_promo) ON UPDATE CASCADE;
 C   ALTER TABLE ONLY public."Compra" DROP CONSTRAINT "Compra_PromoFK";
       public          postgres    false    221    241    3561                       2606    16666    Compra Compra_UsuarioFk    FK CONSTRAINT     �   ALTER TABLE ONLY public."Compra"
    ADD CONSTRAINT "Compra_UsuarioFk" FOREIGN KEY (id_usuario) REFERENCES public."Usuario"(id_usuario) ON UPDATE CASCADE;
 E   ALTER TABLE ONLY public."Compra" DROP CONSTRAINT "Compra_UsuarioFk";
       public          postgres    false    217    3555    241                       2606    16604 /   Dispositivo_Aplicacion Dispositivo_AplicacionFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Dispositivo_Aplicacion"
    ADD CONSTRAINT "Dispositivo_AplicacionFK" FOREIGN KEY (id_producto) REFERENCES public."Aplicacion"(id_producto) ON UPDATE CASCADE ON DELETE CASCADE;
 ]   ALTER TABLE ONLY public."Dispositivo_Aplicacion" DROP CONSTRAINT "Dispositivo_AplicacionFK";
       public          postgres    false    232    234    3573            �           2606    16585 "   Dispositivo Dispositivo_ProductoFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Dispositivo"
    ADD CONSTRAINT "Dispositivo_ProductoFK" FOREIGN KEY (id_producto) REFERENCES public."Producto"(id_producto) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 P   ALTER TABLE ONLY public."Dispositivo" DROP CONSTRAINT "Dispositivo_ProductoFK";
       public          postgres    false    229    3569    227            �           2606    16506    Paises_Promo Pais_PromoFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Paises_Promo"
    ADD CONSTRAINT "Pais_PromoFK" FOREIGN KEY (id_promo) REFERENCES public."Promocion"(id_promo) ON UPDATE CASCADE ON DELETE CASCADE;
 G   ALTER TABLE ONLY public."Paises_Promo" DROP CONSTRAINT "Pais_PromoFK";
       public          postgres    false    221    223    3561            �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �     