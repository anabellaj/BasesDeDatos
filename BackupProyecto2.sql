PGDMP  .    ;            
    {         	   Proyecto3    16.1    16.0 �    a           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            b           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            c           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            d           1262    17146 	   Proyecto3    DATABASE        CREATE DATABASE "Proyecto3" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'Spanish_Mexico.1252';
    DROP DATABASE "Proyecto3";
                postgres    false            e           1247    17148    Genero    DOMAIN     �   CREATE DOMAIN public."Genero" AS text
	CONSTRAINT check_domain CHECK ((VALUE = ANY (ARRAY['Pop'::text, 'Rock'::text, 'Balada'::text, 'Electronica'::text, 'Punk'::text, 'Otro'::text])));
    DROP DOMAIN public."Genero";
       public          postgres    false            i           1247    17151    Tematica    DOMAIN     �   CREATE DOMAIN public."Tematica" AS text
	CONSTRAINT check_domain CHECK ((VALUE = ANY (ARRAY['juegos'::text, 'cocina'::text, 'lectura'::text, 'otro'::text])));
    DROP DOMAIN public."Tematica";
       public          postgres    false            m           1247    17154    Tipo_Proveedor    DOMAIN     �   CREATE DOMAIN public."Tipo_Proveedor" AS text
	CONSTRAINT check_domain CHECK ((VALUE = ANY (ARRAY['Desarrollador'::text, 'Empresa'::text])));
 %   DROP DOMAIN public."Tipo_Proveedor";
       public          postgres    false            �            1255    17156    calcular_duracion()    FUNCTION     �   CREATE FUNCTION public.calcular_duracion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN 
	UPDATE public."Promocion"
		SET duracion_promocion =  fecha_fin-fecha_inicio;
	RETURN NEW;
END;
$$;
 *   DROP FUNCTION public.calcular_duracion();
       public          postgres    false            �            1255    17353    calcular_puntuacion()    FUNCTION     8  CREATE FUNCTION public.calcular_puntuacion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE suma_ratings smallint:=(SELECT SUM("C".rating) FROM public."Compra" AS "C");
DECLARE cantidad_compras smallint:=(SELECT COUNT("C".id_producto) FROM public."Compra" AS "C" JOIN public."Producto" AS "P" ON "C".id_producto = "P".id_producto);
BEGIN
	IF cantidad_compras =0
	Then cantidad_compras = 1;
	END IF;
	
	IF suma_ratings IS NULL
	Then suma_ratings = 0;
	END IF;
	
	Update public."Producto"
		SET puntuacion = suma_ratings/cantidad_compras;
	RETURN NEW;
	
END;
$$;
 ,   DROP FUNCTION public.calcular_puntuacion();
       public          postgres    false            �            1255    17157    contar_unidades_vendidas()    FUNCTION     �  CREATE FUNCTION public.contar_unidades_vendidas() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE auxiliar smallint:= (Select COUNT("C".id_producto) From public."Cancion" AS "C"  JOIN public."Compra" AS "CO" ON "C".id_producto = "CO".id_producto ) ;
BEGIN
	IF auxiliar IS NULL 
	Then auxiliar = 0;
	END IF; 
	
	Update public."Cancion"
		SET unidades_vendidas = auxiliar;
	RETURN NEW;
	
END;
$$;
 1   DROP FUNCTION public.contar_unidades_vendidas();
       public          postgres    false            �            1259    17158 
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
       public         heap    postgres    false    873            �            1259    17166    Aplicacion_id_producto_seq    SEQUENCE     �   CREATE SEQUENCE public."Aplicacion_id_producto_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public."Aplicacion_id_producto_seq";
       public          postgres    false    215            e           0    0    Aplicacion_id_producto_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public."Aplicacion_id_producto_seq" OWNED BY public."Aplicacion".id_producto;
          public          postgres    false    216            �            1259    17167    Aplicacion_id_proveedor_seq    SEQUENCE     �   CREATE SEQUENCE public."Aplicacion_id_proveedor_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public."Aplicacion_id_proveedor_seq";
       public          postgres    false    215            f           0    0    Aplicacion_id_proveedor_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public."Aplicacion_id_proveedor_seq" OWNED BY public."Aplicacion".id_proveedor;
          public          postgres    false    217            �            1259    17168    Artista    TABLE       CREATE TABLE public."Artista" (
    id_artista bigint NOT NULL,
    nom_artistico text NOT NULL,
    nombre_casa text DEFAULT 'Independiente'::text,
    fecha_inicio date,
    fecha_fin date,
    CONSTRAINT check_fecha CHECK ((fecha_inicio < fecha_fin))
);
    DROP TABLE public."Artista";
       public         heap    postgres    false            �            1259    17175    Artista_id_artista_seq    SEQUENCE     �   CREATE SEQUENCE public."Artista_id_artista_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public."Artista_id_artista_seq";
       public          postgres    false    218            g           0    0    Artista_id_artista_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public."Artista_id_artista_seq" OWNED BY public."Artista".id_artista;
          public          postgres    false    219            �            1259    17176    Cancion    TABLE     2  CREATE TABLE public."Cancion" (
    id_producto bigint NOT NULL,
    nom_cancion text NOT NULL,
    fecha_lanz date NOT NULL,
    duracion_cancion smallint NOT NULL,
    genero public."Genero" NOT NULL,
    unidades_vendidas bigint DEFAULT 0,
    nom_disco text NOT NULL,
    id_artista bigint NOT NULL
);
    DROP TABLE public."Cancion";
       public         heap    postgres    false    869            �            1259    17182    Cancion_id_artista_seq    SEQUENCE     �   CREATE SEQUENCE public."Cancion_id_artista_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public."Cancion_id_artista_seq";
       public          postgres    false    220            h           0    0    Cancion_id_artista_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public."Cancion_id_artista_seq" OWNED BY public."Cancion".id_artista;
          public          postgres    false    221            �            1259    17183    Cancion_id_producto_seq    SEQUENCE     �   CREATE SEQUENCE public."Cancion_id_producto_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public."Cancion_id_producto_seq";
       public          postgres    false    220            i           0    0    Cancion_id_producto_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public."Cancion_id_producto_seq" OWNED BY public."Cancion".id_producto;
          public          postgres    false    222            �            1259    17184    Casa_Disquera    TABLE     `   CREATE TABLE public."Casa_Disquera" (
    nombre_casa text NOT NULL,
    direccion_casa text
);
 #   DROP TABLE public."Casa_Disquera";
       public         heap    postgres    false            �            1259    17189    Compra    TABLE     �   CREATE TABLE public."Compra" (
    id_usuario bigint NOT NULL,
    id_producto bigint NOT NULL,
    id_promo bigint NOT NULL,
    fecha_compra date NOT NULL,
    rating smallint NOT NULL,
    monto smallint NOT NULL
);
    DROP TABLE public."Compra";
       public         heap    postgres    false            �            1259    17192    Compra_id_producto_seq    SEQUENCE     �   CREATE SEQUENCE public."Compra_id_producto_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public."Compra_id_producto_seq";
       public          postgres    false    224            j           0    0    Compra_id_producto_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public."Compra_id_producto_seq" OWNED BY public."Compra".id_producto;
          public          postgres    false    225            �            1259    17193    Compra_id_promo_seq    SEQUENCE     ~   CREATE SEQUENCE public."Compra_id_promo_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public."Compra_id_promo_seq";
       public          postgres    false    224            k           0    0    Compra_id_promo_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public."Compra_id_promo_seq" OWNED BY public."Compra".id_promo;
          public          postgres    false    226            �            1259    17194    Compra_id_usuario_seq    SEQUENCE     �   CREATE SEQUENCE public."Compra_id_usuario_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public."Compra_id_usuario_seq";
       public          postgres    false    224            l           0    0    Compra_id_usuario_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public."Compra_id_usuario_seq" OWNED BY public."Compra".id_usuario;
          public          postgres    false    227            �            1259    17195    Dispositivo    TABLE     �  CREATE TABLE public."Dispositivo" (
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
       public         heap    postgres    false            �            1259    17203    Dispositivo_Aplicacion    TABLE     |   CREATE TABLE public."Dispositivo_Aplicacion" (
    id_producto bigint NOT NULL,
    dispositivo_compatible text NOT NULL
);
 ,   DROP TABLE public."Dispositivo_Aplicacion";
       public         heap    postgres    false            �            1259    17208 &   Dispositivo_Aplicacion_id_producto_seq    SEQUENCE     �   CREATE SEQUENCE public."Dispositivo_Aplicacion_id_producto_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ?   DROP SEQUENCE public."Dispositivo_Aplicacion_id_producto_seq";
       public          postgres    false    229            m           0    0 &   Dispositivo_Aplicacion_id_producto_seq    SEQUENCE OWNED BY     u   ALTER SEQUENCE public."Dispositivo_Aplicacion_id_producto_seq" OWNED BY public."Dispositivo_Aplicacion".id_producto;
          public          postgres    false    230            �            1259    17209    Dispositivo_id_producto_seq    SEQUENCE     �   CREATE SEQUENCE public."Dispositivo_id_producto_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public."Dispositivo_id_producto_seq";
       public          postgres    false    228            n           0    0    Dispositivo_id_producto_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public."Dispositivo_id_producto_seq" OWNED BY public."Dispositivo".id_producto;
          public          postgres    false    231            �            1259    17210    Paises_Promo    TABLE     ]   CREATE TABLE public."Paises_Promo" (
    id_promo bigint NOT NULL,
    pais text NOT NULL
);
 "   DROP TABLE public."Paises_Promo";
       public         heap    postgres    false            �            1259    17215    Paises_Promo_id_promo_seq    SEQUENCE     �   CREATE SEQUENCE public."Paises_Promo_id_promo_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public."Paises_Promo_id_promo_seq";
       public          postgres    false    232            o           0    0    Paises_Promo_id_promo_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public."Paises_Promo_id_promo_seq" OWNED BY public."Paises_Promo".id_promo;
          public          postgres    false    233            �            1259    17216    Producto    TABLE     ;  CREATE TABLE public."Producto" (
    id_producto bigint NOT NULL,
    costo real NOT NULL,
    puntuacion real DEFAULT 0,
    CONSTRAINT check_costo CHECK ((costo > (0)::double precision)),
    CONSTRAINT check_puntuacion CHECK (((puntuacion >= (0)::double precision) AND (puntuacion <= (5)::double precision)))
);
    DROP TABLE public."Producto";
       public         heap    postgres    false            �            1259    17222    Producto_id_producto_seq    SEQUENCE     �   CREATE SEQUENCE public."Producto_id_producto_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public."Producto_id_producto_seq";
       public          postgres    false    234            p           0    0    Producto_id_producto_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public."Producto_id_producto_seq" OWNED BY public."Producto".id_producto;
          public          postgres    false    235            �            1259    17223 	   Promocion    TABLE     w  CREATE TABLE public."Promocion" (
    id_promo bigint NOT NULL,
    fecha_inicio date NOT NULL,
    fecha_fin date NOT NULL,
    duracion_promocion smallint,
    descuento real NOT NULL,
    CONSTRAINT check_descuento CHECK (((descuento >= (0)::double precision) AND (descuento <= (100)::double precision))),
    CONSTRAINT check_fecha CHECK ((fecha_fin >= fecha_inicio))
);
    DROP TABLE public."Promocion";
       public         heap    postgres    false            �            1259    17228    Promocion_id_promo_seq    SEQUENCE     �   CREATE SEQUENCE public."Promocion_id_promo_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public."Promocion_id_promo_seq";
       public          postgres    false    236            q           0    0    Promocion_id_promo_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public."Promocion_id_promo_seq" OWNED BY public."Promocion".id_promo;
          public          postgres    false    237            �            1259    17229 	   Proveedor    TABLE     �  CREATE TABLE public."Proveedor" (
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
       public         heap    postgres    false    877            �            1259    17237    Proveedor_id_proveedor_seq    SEQUENCE     �   CREATE SEQUENCE public."Proveedor_id_proveedor_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public."Proveedor_id_proveedor_seq";
       public          postgres    false    238            r           0    0    Proveedor_id_proveedor_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public."Proveedor_id_proveedor_seq" OWNED BY public."Proveedor".id_proveedor;
          public          postgres    false    239            �            1259    17238    Usuario    TABLE     =  CREATE TABLE public."Usuario" (
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
       public         heap    postgres    false            �            1259    17243    Usuario_id_usuario_seq    SEQUENCE     �   CREATE SEQUENCE public."Usuario_id_usuario_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public."Usuario_id_usuario_seq";
       public          postgres    false    240            s           0    0    Usuario_id_usuario_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public."Usuario_id_usuario_seq" OWNED BY public."Usuario".id_usuario;
          public          postgres    false    241            c           2604    17244    Aplicacion id_producto    DEFAULT     �   ALTER TABLE ONLY public."Aplicacion" ALTER COLUMN id_producto SET DEFAULT nextval('public."Aplicacion_id_producto_seq"'::regclass);
 G   ALTER TABLE public."Aplicacion" ALTER COLUMN id_producto DROP DEFAULT;
       public          postgres    false    216    215            d           2604    17245    Aplicacion id_proveedor    DEFAULT     �   ALTER TABLE ONLY public."Aplicacion" ALTER COLUMN id_proveedor SET DEFAULT nextval('public."Aplicacion_id_proveedor_seq"'::regclass);
 H   ALTER TABLE public."Aplicacion" ALTER COLUMN id_proveedor DROP DEFAULT;
       public          postgres    false    217    215            e           2604    17246    Artista id_artista    DEFAULT     |   ALTER TABLE ONLY public."Artista" ALTER COLUMN id_artista SET DEFAULT nextval('public."Artista_id_artista_seq"'::regclass);
 C   ALTER TABLE public."Artista" ALTER COLUMN id_artista DROP DEFAULT;
       public          postgres    false    219    218            g           2604    17247    Cancion id_producto    DEFAULT     ~   ALTER TABLE ONLY public."Cancion" ALTER COLUMN id_producto SET DEFAULT nextval('public."Cancion_id_producto_seq"'::regclass);
 D   ALTER TABLE public."Cancion" ALTER COLUMN id_producto DROP DEFAULT;
       public          postgres    false    222    220            i           2604    17248    Cancion id_artista    DEFAULT     |   ALTER TABLE ONLY public."Cancion" ALTER COLUMN id_artista SET DEFAULT nextval('public."Cancion_id_artista_seq"'::regclass);
 C   ALTER TABLE public."Cancion" ALTER COLUMN id_artista DROP DEFAULT;
       public          postgres    false    221    220            j           2604    17249    Compra id_usuario    DEFAULT     z   ALTER TABLE ONLY public."Compra" ALTER COLUMN id_usuario SET DEFAULT nextval('public."Compra_id_usuario_seq"'::regclass);
 B   ALTER TABLE public."Compra" ALTER COLUMN id_usuario DROP DEFAULT;
       public          postgres    false    227    224            k           2604    17250    Compra id_producto    DEFAULT     |   ALTER TABLE ONLY public."Compra" ALTER COLUMN id_producto SET DEFAULT nextval('public."Compra_id_producto_seq"'::regclass);
 C   ALTER TABLE public."Compra" ALTER COLUMN id_producto DROP DEFAULT;
       public          postgres    false    225    224            l           2604    17251    Compra id_promo    DEFAULT     v   ALTER TABLE ONLY public."Compra" ALTER COLUMN id_promo SET DEFAULT nextval('public."Compra_id_promo_seq"'::regclass);
 @   ALTER TABLE public."Compra" ALTER COLUMN id_promo DROP DEFAULT;
       public          postgres    false    226    224            m           2604    17252    Dispositivo id_producto    DEFAULT     �   ALTER TABLE ONLY public."Dispositivo" ALTER COLUMN id_producto SET DEFAULT nextval('public."Dispositivo_id_producto_seq"'::regclass);
 H   ALTER TABLE public."Dispositivo" ALTER COLUMN id_producto DROP DEFAULT;
       public          postgres    false    231    228            n           2604    17253 "   Dispositivo_Aplicacion id_producto    DEFAULT     �   ALTER TABLE ONLY public."Dispositivo_Aplicacion" ALTER COLUMN id_producto SET DEFAULT nextval('public."Dispositivo_Aplicacion_id_producto_seq"'::regclass);
 S   ALTER TABLE public."Dispositivo_Aplicacion" ALTER COLUMN id_producto DROP DEFAULT;
       public          postgres    false    230    229            o           2604    17254    Paises_Promo id_promo    DEFAULT     �   ALTER TABLE ONLY public."Paises_Promo" ALTER COLUMN id_promo SET DEFAULT nextval('public."Paises_Promo_id_promo_seq"'::regclass);
 F   ALTER TABLE public."Paises_Promo" ALTER COLUMN id_promo DROP DEFAULT;
       public          postgres    false    233    232            p           2604    17255    Producto id_producto    DEFAULT     �   ALTER TABLE ONLY public."Producto" ALTER COLUMN id_producto SET DEFAULT nextval('public."Producto_id_producto_seq"'::regclass);
 E   ALTER TABLE public."Producto" ALTER COLUMN id_producto DROP DEFAULT;
       public          postgres    false    235    234            r           2604    17256    Promocion id_promo    DEFAULT     |   ALTER TABLE ONLY public."Promocion" ALTER COLUMN id_promo SET DEFAULT nextval('public."Promocion_id_promo_seq"'::regclass);
 C   ALTER TABLE public."Promocion" ALTER COLUMN id_promo DROP DEFAULT;
       public          postgres    false    237    236            s           2604    17257    Proveedor id_proveedor    DEFAULT     �   ALTER TABLE ONLY public."Proveedor" ALTER COLUMN id_proveedor SET DEFAULT nextval('public."Proveedor_id_proveedor_seq"'::regclass);
 G   ALTER TABLE public."Proveedor" ALTER COLUMN id_proveedor DROP DEFAULT;
       public          postgres    false    239    238            u           2604    17258    Usuario id_usuario    DEFAULT     |   ALTER TABLE ONLY public."Usuario" ALTER COLUMN id_usuario SET DEFAULT nextval('public."Usuario_id_usuario_seq"'::regclass);
 C   ALTER TABLE public."Usuario" ALTER COLUMN id_usuario DROP DEFAULT;
       public          postgres    false    241    240            D          0    17158 
   Aplicacion 
   TABLE DATA           �   COPY public."Aplicacion" (id_producto, tamano_mb, version, nombre_aplicacion, descripcion, version_ios, tematica, id_proveedor) FROM stdin;
    public          postgres    false    215   ڨ       G          0    17168    Artista 
   TABLE DATA           d   COPY public."Artista" (id_artista, nom_artistico, nombre_casa, fecha_inicio, fecha_fin) FROM stdin;
    public          postgres    false    218   ��       I          0    17176    Cancion 
   TABLE DATA           �   COPY public."Cancion" (id_producto, nom_cancion, fecha_lanz, duracion_cancion, genero, unidades_vendidas, nom_disco, id_artista) FROM stdin;
    public          postgres    false    220   �       L          0    17184    Casa_Disquera 
   TABLE DATA           F   COPY public."Casa_Disquera" (nombre_casa, direccion_casa) FROM stdin;
    public          postgres    false    223   1�       M          0    17189    Compra 
   TABLE DATA           b   COPY public."Compra" (id_usuario, id_producto, id_promo, fecha_compra, rating, monto) FROM stdin;
    public          postgres    false    224   N�       Q          0    17195    Dispositivo 
   TABLE DATA           `   COPY public."Dispositivo" (id_producto, modelo, generacion, version_ios, capacidad) FROM stdin;
    public          postgres    false    228   k�       R          0    17203    Dispositivo_Aplicacion 
   TABLE DATA           W   COPY public."Dispositivo_Aplicacion" (id_producto, dispositivo_compatible) FROM stdin;
    public          postgres    false    229   ��       U          0    17210    Paises_Promo 
   TABLE DATA           8   COPY public."Paises_Promo" (id_promo, pais) FROM stdin;
    public          postgres    false    232   ��       W          0    17216    Producto 
   TABLE DATA           D   COPY public."Producto" (id_producto, costo, puntuacion) FROM stdin;
    public          postgres    false    234   ©       Y          0    17223 	   Promocion 
   TABLE DATA           g   COPY public."Promocion" (id_promo, fecha_inicio, fecha_fin, duracion_promocion, descuento) FROM stdin;
    public          postgres    false    236   ߩ       [          0    17229 	   Proveedor 
   TABLE DATA           �   COPY public."Proveedor" (id_proveedor, nombre_proveedor, correo_proveedor, direccion_proveedor, fecha_afiliacion, tipo_proveedor) FROM stdin;
    public          postgres    false    238   ��       ]          0    17238    Usuario 
   TABLE DATA           �   COPY public."Usuario" (id_usuario, nombre_usuario, apellido_usuario, correo_usuario, ciudad_usuario, pais_usuario, fecha_venc, num_tdc, cod_vvt) FROM stdin;
    public          postgres    false    240   �       t           0    0    Aplicacion_id_producto_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public."Aplicacion_id_producto_seq"', 1, false);
          public          postgres    false    216            u           0    0    Aplicacion_id_proveedor_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public."Aplicacion_id_proveedor_seq"', 1, false);
          public          postgres    false    217            v           0    0    Artista_id_artista_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public."Artista_id_artista_seq"', 1, false);
          public          postgres    false    219            w           0    0    Cancion_id_artista_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public."Cancion_id_artista_seq"', 1, false);
          public          postgres    false    221            x           0    0    Cancion_id_producto_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public."Cancion_id_producto_seq"', 1, false);
          public          postgres    false    222            y           0    0    Compra_id_producto_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public."Compra_id_producto_seq"', 1, false);
          public          postgres    false    225            z           0    0    Compra_id_promo_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public."Compra_id_promo_seq"', 1, false);
          public          postgres    false    226            {           0    0    Compra_id_usuario_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public."Compra_id_usuario_seq"', 1, false);
          public          postgres    false    227            |           0    0 &   Dispositivo_Aplicacion_id_producto_seq    SEQUENCE SET     W   SELECT pg_catalog.setval('public."Dispositivo_Aplicacion_id_producto_seq"', 1, false);
          public          postgres    false    230            }           0    0    Dispositivo_id_producto_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public."Dispositivo_id_producto_seq"', 1, false);
          public          postgres    false    231            ~           0    0    Paises_Promo_id_promo_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public."Paises_Promo_id_promo_seq"', 1, false);
          public          postgres    false    233                       0    0    Producto_id_producto_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public."Producto_id_producto_seq"', 1, false);
          public          postgres    false    235            �           0    0    Promocion_id_promo_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public."Promocion_id_promo_seq"', 1, false);
          public          postgres    false    237            �           0    0    Proveedor_id_proveedor_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public."Proveedor_id_proveedor_seq"', 1, false);
          public          postgres    false    239            �           0    0    Usuario_id_usuario_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public."Usuario_id_usuario_seq"', 1, false);
          public          postgres    false    241            �           2606    17260    Aplicacion Aplicacion_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public."Aplicacion"
    ADD CONSTRAINT "Aplicacion_pkey" PRIMARY KEY (id_producto);
 H   ALTER TABLE ONLY public."Aplicacion" DROP CONSTRAINT "Aplicacion_pkey";
       public            postgres    false    215            �           2606    17262    Artista Artista_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public."Artista"
    ADD CONSTRAINT "Artista_pkey" PRIMARY KEY (id_artista);
 B   ALTER TABLE ONLY public."Artista" DROP CONSTRAINT "Artista_pkey";
       public            postgres    false    218            �           2606    17264    Cancion Cancion_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public."Cancion"
    ADD CONSTRAINT "Cancion_pkey" PRIMARY KEY (id_producto);
 B   ALTER TABLE ONLY public."Cancion" DROP CONSTRAINT "Cancion_pkey";
       public            postgres    false    220            �           2606    17266     Casa_Disquera Casa_Disquera_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY public."Casa_Disquera"
    ADD CONSTRAINT "Casa_Disquera_pkey" PRIMARY KEY (nombre_casa);
 N   ALTER TABLE ONLY public."Casa_Disquera" DROP CONSTRAINT "Casa_Disquera_pkey";
       public            postgres    false    223            �           2606    17268    Compra Compra_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public."Compra"
    ADD CONSTRAINT "Compra_pkey" PRIMARY KEY (id_usuario, id_producto, id_promo, fecha_compra);
 @   ALTER TABLE ONLY public."Compra" DROP CONSTRAINT "Compra_pkey";
       public            postgres    false    224    224    224    224            �           2606    17270 2   Dispositivo_Aplicacion Dispositivo_Aplicacion_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public."Dispositivo_Aplicacion"
    ADD CONSTRAINT "Dispositivo_Aplicacion_pkey" PRIMARY KEY (id_producto, dispositivo_compatible);
 `   ALTER TABLE ONLY public."Dispositivo_Aplicacion" DROP CONSTRAINT "Dispositivo_Aplicacion_pkey";
       public            postgres    false    229    229            �           2606    17272    Dispositivo Dispositivo_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY public."Dispositivo"
    ADD CONSTRAINT "Dispositivo_pkey" PRIMARY KEY (id_producto);
 J   ALTER TABLE ONLY public."Dispositivo" DROP CONSTRAINT "Dispositivo_pkey";
       public            postgres    false    228            �           2606    17274    Paises_Promo Paises_Promo_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public."Paises_Promo"
    ADD CONSTRAINT "Paises_Promo_pkey" PRIMARY KEY (id_promo, pais);
 L   ALTER TABLE ONLY public."Paises_Promo" DROP CONSTRAINT "Paises_Promo_pkey";
       public            postgres    false    232    232            �           2606    17276    Producto Producto_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public."Producto"
    ADD CONSTRAINT "Producto_pkey" PRIMARY KEY (id_producto);
 D   ALTER TABLE ONLY public."Producto" DROP CONSTRAINT "Producto_pkey";
       public            postgres    false    234            �           2606    17278    Promocion Promocion_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public."Promocion"
    ADD CONSTRAINT "Promocion_pkey" PRIMARY KEY (id_promo);
 F   ALTER TABLE ONLY public."Promocion" DROP CONSTRAINT "Promocion_pkey";
       public            postgres    false    236            �           2606    17280    Proveedor Proveedor_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public."Proveedor"
    ADD CONSTRAINT "Proveedor_pkey" PRIMARY KEY (id_proveedor);
 F   ALTER TABLE ONLY public."Proveedor" DROP CONSTRAINT "Proveedor_pkey";
       public            postgres    false    238            �           2606    17282    Usuario Usuario_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public."Usuario"
    ADD CONSTRAINT "Usuario_pkey" PRIMARY KEY (id_usuario);
 B   ALTER TABLE ONLY public."Usuario" DROP CONSTRAINT "Usuario_pkey";
       public            postgres    false    240            �           2606    17283    Usuario check_cod_vvt    CHECK CONSTRAINT     z   ALTER TABLE public."Usuario"
    ADD CONSTRAINT check_cod_vvt CHECK (((cod_vvt >= 100) AND (cod_vvt <= 9999))) NOT VALID;
 <   ALTER TABLE public."Usuario" DROP CONSTRAINT check_cod_vvt;
       public          postgres    false    240    240            �           2606    17284    Usuario check_correo_format    CHECK CONSTRAINT     �   ALTER TABLE public."Usuario"
    ADD CONSTRAINT check_correo_format CHECK ((correo_usuario ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'::text)) NOT VALID;
 B   ALTER TABLE public."Usuario" DROP CONSTRAINT check_correo_format;
       public          postgres    false    240    240            �           2606    17286    Usuario check_correo_unico 
   CONSTRAINT     t   ALTER TABLE ONLY public."Usuario"
    ADD CONSTRAINT check_correo_unico UNIQUE NULLS NOT DISTINCT (correo_usuario);
 F   ALTER TABLE ONLY public."Usuario" DROP CONSTRAINT check_correo_unico;
       public            postgres    false    240            �           2606    17288    Proveedor check_correo_unique 
   CONSTRAINT     y   ALTER TABLE ONLY public."Proveedor"
    ADD CONSTRAINT check_correo_unique UNIQUE NULLS NOT DISTINCT (correo_proveedor);
 I   ALTER TABLE ONLY public."Proveedor" DROP CONSTRAINT check_correo_unique;
       public            postgres    false    238            z           2606    17289    Cancion check_duracion    CHECK CONSTRAINT     i   ALTER TABLE public."Cancion"
    ADD CONSTRAINT check_duracion CHECK ((duracion_cancion > 0)) NOT VALID;
 =   ALTER TABLE public."Cancion" DROP CONSTRAINT check_duracion;
       public          postgres    false    220    220            �           2606    17290    Usuario check_fecha    CHECK CONSTRAINT     l   ALTER TABLE public."Usuario"
    ADD CONSTRAINT check_fecha CHECK ((fecha_venc >= CURRENT_DATE)) NOT VALID;
 :   ALTER TABLE public."Usuario" DROP CONSTRAINT check_fecha;
       public          postgres    false    240    240            |           2606    17291    Compra check_fecha    CHECK CONSTRAINT     m   ALTER TABLE public."Compra"
    ADD CONSTRAINT check_fecha CHECK ((fecha_compra <= CURRENT_DATE)) NOT VALID;
 9   ALTER TABLE public."Compra" DROP CONSTRAINT check_fecha;
       public          postgres    false    224    224            �           2606    17292    Usuario check_num_tdc    CHECK CONSTRAINT     �   ALTER TABLE public."Usuario"
    ADD CONSTRAINT check_num_tdc CHECK (((num_tdc >= '100000000000000'::bigint) AND (num_tdc <= '9999999999999999'::bigint))) NOT VALID;
 <   ALTER TABLE public."Usuario" DROP CONSTRAINT check_num_tdc;
       public          postgres    false    240    240            }           2606    17293    Compra check_rating    CHECK CONSTRAINT     q   ALTER TABLE public."Compra"
    ADD CONSTRAINT check_rating CHECK (((rating >= 0) AND (rating <= 5))) NOT VALID;
 :   ALTER TABLE public."Compra" DROP CONSTRAINT check_rating;
       public          postgres    false    224    224            {           2606    17294    Cancion check_unidades    CHECK CONSTRAINT     k   ALTER TABLE public."Cancion"
    ADD CONSTRAINT check_unidades CHECK ((unidades_vendidas >= 0)) NOT VALID;
 =   ALTER TABLE public."Cancion" DROP CONSTRAINT check_unidades;
       public          postgres    false    220    220            �           2620    17295     Promocion trigger_duracion_promo    TRIGGER     �   CREATE TRIGGER trigger_duracion_promo BEFORE INSERT OR UPDATE OF fecha_inicio, fecha_fin ON public."Promocion" FOR EACH ROW EXECUTE FUNCTION public.calcular_duracion();
 ;   DROP TRIGGER trigger_duracion_promo ON public."Promocion";
       public          postgres    false    236    242    236    236            �           2620    17354    Producto trigger_puntuacion    TRIGGER     �   CREATE TRIGGER trigger_puntuacion BEFORE INSERT OR UPDATE ON public."Producto" FOR EACH ROW EXECUTE FUNCTION public.calcular_puntuacion();
 6   DROP TRIGGER trigger_puntuacion ON public."Producto";
       public          postgres    false    244    234            �           2620    17296 !   Cancion trigger_unidades_vendidas    TRIGGER     �   CREATE TRIGGER trigger_unidades_vendidas AFTER INSERT OR UPDATE OF id_producto ON public."Cancion" FOR EACH ROW EXECUTE FUNCTION public.contar_unidades_vendidas();
 <   DROP TRIGGER trigger_unidades_vendidas ON public."Cancion";
       public          postgres    false    220    220    243            �           2606    17297 !   Aplicacion Aplicacion_Producto_FK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Aplicacion"
    ADD CONSTRAINT "Aplicacion_Producto_FK" FOREIGN KEY (id_producto) REFERENCES public."Producto"(id_producto) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 O   ALTER TABLE ONLY public."Aplicacion" DROP CONSTRAINT "Aplicacion_Producto_FK";
       public          postgres    false    234    4764    215            �           2606    17302 "   Aplicacion Aplicacion_Proveedor_FK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Aplicacion"
    ADD CONSTRAINT "Aplicacion_Proveedor_FK" FOREIGN KEY (id_proveedor) REFERENCES public."Proveedor"(id_proveedor);
 P   ALTER TABLE ONLY public."Aplicacion" DROP CONSTRAINT "Aplicacion_Proveedor_FK";
       public          postgres    false    238    4768    215            �           2606    17307    Artista Artista_DisqueraFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Artista"
    ADD CONSTRAINT "Artista_DisqueraFK" FOREIGN KEY (nombre_casa) REFERENCES public."Casa_Disquera"(nombre_casa) ON UPDATE CASCADE ON DELETE SET DEFAULT;
 H   ALTER TABLE ONLY public."Artista" DROP CONSTRAINT "Artista_DisqueraFK";
       public          postgres    false    4754    223    218            �           2606    17312    Cancion Cancion_ArtistaFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Cancion"
    ADD CONSTRAINT "Cancion_ArtistaFK" FOREIGN KEY (id_artista) REFERENCES public."Artista"(id_artista) ON UPDATE CASCADE;
 G   ALTER TABLE ONLY public."Cancion" DROP CONSTRAINT "Cancion_ArtistaFK";
       public          postgres    false    4750    218    220            �           2606    17317    Cancion Cancion_ProductoFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Cancion"
    ADD CONSTRAINT "Cancion_ProductoFK" FOREIGN KEY (id_producto) REFERENCES public."Producto"(id_producto) ON UPDATE CASCADE ON DELETE CASCADE;
 H   ALTER TABLE ONLY public."Cancion" DROP CONSTRAINT "Cancion_ProductoFK";
       public          postgres    false    220    4764    234            �           2606    17322    Compra Compra_ProductoFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Compra"
    ADD CONSTRAINT "Compra_ProductoFK" FOREIGN KEY (id_producto) REFERENCES public."Producto"(id_producto) ON UPDATE CASCADE;
 F   ALTER TABLE ONLY public."Compra" DROP CONSTRAINT "Compra_ProductoFK";
       public          postgres    false    4764    234    224            �           2606    17327    Compra Compra_PromoFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Compra"
    ADD CONSTRAINT "Compra_PromoFK" FOREIGN KEY (id_promo) REFERENCES public."Promocion"(id_promo) ON UPDATE CASCADE;
 C   ALTER TABLE ONLY public."Compra" DROP CONSTRAINT "Compra_PromoFK";
       public          postgres    false    224    236    4766            �           2606    17332    Compra Compra_UsuarioFk    FK CONSTRAINT     �   ALTER TABLE ONLY public."Compra"
    ADD CONSTRAINT "Compra_UsuarioFk" FOREIGN KEY (id_usuario) REFERENCES public."Usuario"(id_usuario) ON UPDATE CASCADE;
 E   ALTER TABLE ONLY public."Compra" DROP CONSTRAINT "Compra_UsuarioFk";
       public          postgres    false    240    224    4772            �           2606    17337 /   Dispositivo_Aplicacion Dispositivo_AplicacionFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Dispositivo_Aplicacion"
    ADD CONSTRAINT "Dispositivo_AplicacionFK" FOREIGN KEY (id_producto) REFERENCES public."Aplicacion"(id_producto) ON UPDATE CASCADE ON DELETE CASCADE;
 ]   ALTER TABLE ONLY public."Dispositivo_Aplicacion" DROP CONSTRAINT "Dispositivo_AplicacionFK";
       public          postgres    false    229    4748    215            �           2606    17342 "   Dispositivo Dispositivo_ProductoFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Dispositivo"
    ADD CONSTRAINT "Dispositivo_ProductoFK" FOREIGN KEY (id_producto) REFERENCES public."Producto"(id_producto) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 P   ALTER TABLE ONLY public."Dispositivo" DROP CONSTRAINT "Dispositivo_ProductoFK";
       public          postgres    false    234    4764    228            �           2606    17347    Paises_Promo Pais_PromoFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Paises_Promo"
    ADD CONSTRAINT "Pais_PromoFK" FOREIGN KEY (id_promo) REFERENCES public."Promocion"(id_promo) ON UPDATE CASCADE ON DELETE CASCADE;
 G   ALTER TABLE ONLY public."Paises_Promo" DROP CONSTRAINT "Pais_PromoFK";
       public          postgres    false    4766    232    236            D      x������ � �      G      x������ � �      I      x������ � �      L      x������ � �      M      x������ � �      Q      x������ � �      R      x������ � �      U      x������ � �      W      x������ � �      Y      x������ � �      [      x������ � �      ]      x������ � �     