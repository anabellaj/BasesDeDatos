PGDMP      $            
    {            Proyecto Inserts    16.0    16.0 �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    24797    Proyecto Inserts    DATABASE     t   CREATE DATABASE "Proyecto Inserts" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'C';
 "   DROP DATABASE "Proyecto Inserts";
                postgres    false            l           1247    24799    Genero    DOMAIN     �   CREATE DOMAIN public."Genero" AS text
	CONSTRAINT check_domain CHECK ((VALUE = ANY (ARRAY['Pop'::text, 'Rock'::text, 'Balada'::text, 'Electronica'::text, 'Punk'::text, 'Otro'::text])));
    DROP DOMAIN public."Genero";
       public          postgres    false            p           1247    24802    Tematica    DOMAIN     �   CREATE DOMAIN public."Tematica" AS text
	CONSTRAINT check_domain CHECK ((VALUE = ANY (ARRAY['juegos'::text, 'cocina'::text, 'lectura'::text, 'otro'::text])));
    DROP DOMAIN public."Tematica";
       public          postgres    false            t           1247    24805    Tipo_Proveedor    DOMAIN     �   CREATE DOMAIN public."Tipo_Proveedor" AS text
	CONSTRAINT check_domain CHECK ((VALUE = ANY (ARRAY['Desarrollador'::text, 'Empresa'::text])));
 %   DROP DOMAIN public."Tipo_Proveedor";
       public          postgres    false            �            1255    24807    calcular_duracion()    FUNCTION     �   CREATE FUNCTION public.calcular_duracion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN 
	NEW.duracion_promocion =  NEW.fecha_fin- NEW.fecha_inicio;
	RETURN NEW;
END;
$$;
 *   DROP FUNCTION public.calcular_duracion();
       public          postgres    false            �            1255    24808    calcular_fecha_fin_pe()    FUNCTION     �   CREATE FUNCTION public.calcular_fecha_fin_pe() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
	NEW.fecha_fin = NEW.fecha_inicio + interval '1 month';
	RETURN NEW;
END;
	$$;
 .   DROP FUNCTION public.calcular_fecha_fin_pe();
       public          postgres    false            �            1255    24809    calcular_promedio_puntuacion()    FUNCTION     ]  CREATE FUNCTION public.calcular_promedio_puntuacion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE auxiliar real;
BEGIN 
	SELECT AVG(rating) 
	INTO auxiliar
	FROM public."Compra" 
	WHERE id_producto = NEW.id_producto ;
	
    UPDATE public."Producto"
	SET puntuacion = auxiliar
	WHERE NEW.id_producto = id_producto;
	RETURN NEW;
END;

	$$;
 5   DROP FUNCTION public.calcular_promedio_puntuacion();
       public          postgres    false            �            1255    24810    contar_unidades_vendidas()    FUNCTION     4  CREATE FUNCTION public.contar_unidades_vendidas() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE auxiliar smallint;
BEGIN
	
IF EXISTS (SELECT "CA".id_producto FROM public."Cancion" AS "CA" WHERE "CA".id_producto = NEW.id_producto) THEN
	SELECT COUNT("Ca".id_producto)
	INTO auxiliar
	FROM public."Compra" AS "C" JOIN public."Cancion" AS "Ca"
	ON "C".id_producto = "Ca".id_producto
	WHERE "Ca".id_producto = NEW.id_producto;

	
	Update public."Cancion" 
		SET unidades_vendidas = auxiliar
		WHERE NEW.id_producto = id_producto;
END IF;
RETURN NEW;
END;
$$;
 1   DROP FUNCTION public.contar_unidades_vendidas();
       public          postgres    false            �            1255    24811    crear_promo_especial()    FUNCTION       CREATE FUNCTION public.crear_promo_especial() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE contador integer;

BEGIN

	SELECT count("C".id_producto)
	INTO contador
	FROM public."Compra" AS "C"
	WHERE NEW.fecha_compra = "C".fecha_compra;
	
	IF contador > 3 AND NOT(EXISTS (SELECT "PE".id_usuario FROM public."Promocion_Especial" AS "PE" WHERE NEW.id_usuario = "PE".id_usuario )) THEN
		INSERT INTO public."Promocion_Especial"
		VALUES (DEFAULT, NEW.fecha_compra, null, NEW.id_usuario);

	END IF;
	RETURN NEW;
END;$$;
 -   DROP FUNCTION public.crear_promo_especial();
       public          postgres    false                       1255    24812    verificar_compatibilidad()    FUNCTION     �  CREATE FUNCTION public.verificar_compatibilidad() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE version_ios_app text[];
DECLARE version_ios_disp text[];
DECLARE compatible boolean := true;
DECLARE D record;
BEGIN

	IF EXISTS(SELECT "APP".id_producto FROM public."Aplicacion" AS "APP" WHERE new.id_producto = "APP".id_producto) THEN
		SELECT string_to_array(version_ios, '.')
		INTO version_ios_app
		FROM public."Aplicacion" AS "A"
		WHERE "A".id_producto = NEW.id_producto;



		FOR D IN (SELECT "D".id_producto, "D".version_ios
				  FROM public."Compra" AS "C" JOIN public."Dispositivo" AS "D"
				  ON "C".id_producto = "D".id_producto
				  WHERE "C".id_usuario = NEW.id_usuario)
		LOOP
			version_ios_disp = string_to_array(D.version_ios,'.');
			RAISE NOTICE 'Long %', array_length(version_ios_app,1);
			FOR V IN REVERSE array_length(version_ios_app,1)..1 LOOP
					IF CAST(version_ios_app[V] AS integer) > CAST(version_ios_disp[V] AS integer) THEN
						compatible = false;  
				END IF;
			END LOOP;
		END LOOP; 

	IF compatible = false THEN 

		RAISE EXCEPTION 'Dispositivo y Aplicacion No Compatibles';
	ELSE
		RETURN NEW;
	END IF;
ELSE
RETURN NEW;
END IF;


END;

			
		$$;
 1   DROP FUNCTION public.verificar_compatibilidad();
       public          postgres    false                       1255    24813    verificar_promo()    FUNCTION     �  CREATE FUNCTION public.verificar_promo() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE id_promo_aplica bigint;
DECLARE descu real := 0 ;
DECLARE pais_selec text;
DECLARE precio real;
BEGIN
	SELECT "P".costo
	INTO precio
	FROM public."Producto" AS "P"
	WHERE NEW.id_producto = "P".id_producto;
		
	SELECT "PE".id_promo_especial
	INTO id_promo_aplica
	FROM public."Promocion_Especial" AS "PE"
	WHERE NEW.id_usuario = "PE".id_usuario AND (NEW.fecha_compra BETWEEN "PE".fecha_inicio AND "PE".fecha_fin);

	IF id_promo_aplica IS NULL THEN
	
		SELECT "U".pais_usuario 
		INTO pais_selec
		FROM public."Usuario" AS "U"
		WHERE NEW.id_usuario = "U".id_usuario;
	
		SELECT "PR".id_promo, "PR".descuento
		INTO id_promo_aplica, descu
		FROM public."Paises_Promo" AS "P" JOIN public."Promocion" AS "PR"
		ON "P".id_promo = "PR".id_promo
		WHERE "P".pais = pais_selec AND (NEW.fecha_compra BETWEEN "PR".fecha_inicio AND "PR".fecha_fin) AND "PR".descuento = (SELECT MAX(descuento) 
																															  FROM public."Promocion");	
	ELSE  
		descu = 30;																														  
	END IF;
	
	IF id_promo_aplica IS NULL THEN
	NEW.monto = precio;
	ELSE
	
	NEW.id_promo = id_promo_aplica;
	NEW.monto = precio - (precio*descu/100);
	END IF;
	RETURN NEW;
	
END;$$;
 (   DROP FUNCTION public.verificar_promo();
       public          postgres    false            �            1259    24814 
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
       public         heap    postgres    false    880            �            1259    24822    Aplicacion_id_producto_seq    SEQUENCE     �   CREATE SEQUENCE public."Aplicacion_id_producto_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public."Aplicacion_id_producto_seq";
       public          postgres    false    215            �           0    0    Aplicacion_id_producto_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public."Aplicacion_id_producto_seq" OWNED BY public."Aplicacion".id_producto;
          public          postgres    false    216            �            1259    24823    Aplicacion_id_proveedor_seq    SEQUENCE     �   CREATE SEQUENCE public."Aplicacion_id_proveedor_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public."Aplicacion_id_proveedor_seq";
       public          postgres    false    215            �           0    0    Aplicacion_id_proveedor_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public."Aplicacion_id_proveedor_seq" OWNED BY public."Aplicacion".id_proveedor;
          public          postgres    false    217            �            1259    24824    Artista    TABLE       CREATE TABLE public."Artista" (
    id_artista bigint NOT NULL,
    nom_artistico text NOT NULL,
    nombre_casa text DEFAULT 'Independiente'::text,
    fecha_inicio date,
    fecha_fin date,
    CONSTRAINT check_fecha CHECK ((fecha_inicio < fecha_fin))
);
    DROP TABLE public."Artista";
       public         heap    postgres    false            �            1259    24831    Artista_id_artista_seq    SEQUENCE     �   CREATE SEQUENCE public."Artista_id_artista_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public."Artista_id_artista_seq";
       public          postgres    false    218            �           0    0    Artista_id_artista_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public."Artista_id_artista_seq" OWNED BY public."Artista".id_artista;
          public          postgres    false    219            �            1259    24832    Cancion    TABLE     2  CREATE TABLE public."Cancion" (
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
       public         heap    postgres    false    876            �            1259    24838    Cancion_id_artista_seq    SEQUENCE     �   CREATE SEQUENCE public."Cancion_id_artista_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public."Cancion_id_artista_seq";
       public          postgres    false    220            �           0    0    Cancion_id_artista_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public."Cancion_id_artista_seq" OWNED BY public."Cancion".id_artista;
          public          postgres    false    221            �            1259    24839    Cancion_id_producto_seq    SEQUENCE     �   CREATE SEQUENCE public."Cancion_id_producto_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public."Cancion_id_producto_seq";
       public          postgres    false    220            �           0    0    Cancion_id_producto_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public."Cancion_id_producto_seq" OWNED BY public."Cancion".id_producto;
          public          postgres    false    222            �            1259    24840    Casa_Disquera    TABLE     `   CREATE TABLE public."Casa_Disquera" (
    nombre_casa text NOT NULL,
    direccion_casa text
);
 #   DROP TABLE public."Casa_Disquera";
       public         heap    postgres    false            �            1259    24845    Compra    TABLE     �   CREATE TABLE public."Compra" (
    id_usuario bigint NOT NULL,
    id_producto bigint NOT NULL,
    fecha_compra date NOT NULL,
    rating smallint NOT NULL,
    monto real,
    id_promo bigint
);
    DROP TABLE public."Compra";
       public         heap    postgres    false            �            1259    24848    Compra_id_producto_seq    SEQUENCE     �   CREATE SEQUENCE public."Compra_id_producto_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public."Compra_id_producto_seq";
       public          postgres    false    224            �           0    0    Compra_id_producto_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public."Compra_id_producto_seq" OWNED BY public."Compra".id_producto;
          public          postgres    false    225            �            1259    24849    Compra_id_promo_seq    SEQUENCE     ~   CREATE SEQUENCE public."Compra_id_promo_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public."Compra_id_promo_seq";
       public          postgres    false    224            �           0    0    Compra_id_promo_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public."Compra_id_promo_seq" OWNED BY public."Compra".id_promo;
          public          postgres    false    226            �            1259    24850    Compra_id_usuario_seq    SEQUENCE     �   CREATE SEQUENCE public."Compra_id_usuario_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public."Compra_id_usuario_seq";
       public          postgres    false    224            �           0    0    Compra_id_usuario_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public."Compra_id_usuario_seq" OWNED BY public."Compra".id_usuario;
          public          postgres    false    227            �            1259    24851    Dispositivo    TABLE     �  CREATE TABLE public."Dispositivo" (
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
       public         heap    postgres    false            �            1259    24859    Dispositivo_Aplicacion    TABLE     |   CREATE TABLE public."Dispositivo_Aplicacion" (
    id_producto bigint NOT NULL,
    dispositivo_compatible text NOT NULL
);
 ,   DROP TABLE public."Dispositivo_Aplicacion";
       public         heap    postgres    false            �            1259    24864 &   Dispositivo_Aplicacion_id_producto_seq    SEQUENCE     �   CREATE SEQUENCE public."Dispositivo_Aplicacion_id_producto_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ?   DROP SEQUENCE public."Dispositivo_Aplicacion_id_producto_seq";
       public          postgres    false    229            �           0    0 &   Dispositivo_Aplicacion_id_producto_seq    SEQUENCE OWNED BY     u   ALTER SEQUENCE public."Dispositivo_Aplicacion_id_producto_seq" OWNED BY public."Dispositivo_Aplicacion".id_producto;
          public          postgres    false    230            �            1259    24865    Dispositivo_id_producto_seq    SEQUENCE     �   CREATE SEQUENCE public."Dispositivo_id_producto_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public."Dispositivo_id_producto_seq";
       public          postgres    false    228            �           0    0    Dispositivo_id_producto_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public."Dispositivo_id_producto_seq" OWNED BY public."Dispositivo".id_producto;
          public          postgres    false    231            �            1259    24866    Paises_Promo    TABLE     ]   CREATE TABLE public."Paises_Promo" (
    id_promo bigint NOT NULL,
    pais text NOT NULL
);
 "   DROP TABLE public."Paises_Promo";
       public         heap    postgres    false            �            1259    24871    Paises_Promo_id_promo_seq    SEQUENCE     �   CREATE SEQUENCE public."Paises_Promo_id_promo_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public."Paises_Promo_id_promo_seq";
       public          postgres    false    232            �           0    0    Paises_Promo_id_promo_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public."Paises_Promo_id_promo_seq" OWNED BY public."Paises_Promo".id_promo;
          public          postgres    false    233            �            1259    24872    Producto    TABLE     ;  CREATE TABLE public."Producto" (
    id_producto bigint NOT NULL,
    costo real NOT NULL,
    puntuacion real DEFAULT 0,
    CONSTRAINT check_costo CHECK ((costo > (0)::double precision)),
    CONSTRAINT check_puntuacion CHECK (((puntuacion >= (0)::double precision) AND (puntuacion <= (5)::double precision)))
);
    DROP TABLE public."Producto";
       public         heap    postgres    false            �            1259    24878    Producto_id_producto_seq    SEQUENCE     �   CREATE SEQUENCE public."Producto_id_producto_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public."Producto_id_producto_seq";
       public          postgres    false    234            �           0    0    Producto_id_producto_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public."Producto_id_producto_seq" OWNED BY public."Producto".id_producto;
          public          postgres    false    235            �            1259    24879 	   Promocion    TABLE     w  CREATE TABLE public."Promocion" (
    id_promo bigint NOT NULL,
    fecha_inicio date NOT NULL,
    fecha_fin date NOT NULL,
    duracion_promocion smallint,
    descuento real NOT NULL,
    CONSTRAINT check_descuento CHECK (((descuento >= (0)::double precision) AND (descuento <= (100)::double precision))),
    CONSTRAINT check_fecha CHECK ((fecha_fin >= fecha_inicio))
);
    DROP TABLE public."Promocion";
       public         heap    postgres    false            �            1259    24884    Promocion_Especial    TABLE     �   CREATE TABLE public."Promocion_Especial" (
    id_promo_especial bigint NOT NULL,
    fecha_inicio date NOT NULL,
    fecha_fin date,
    id_usuario bigint NOT NULL
);
 (   DROP TABLE public."Promocion_Especial";
       public         heap    postgres    false            �            1259    24887 (   Promocion_Especial_id_promo_especial_seq    SEQUENCE     �   CREATE SEQUENCE public."Promocion_Especial_id_promo_especial_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 A   DROP SEQUENCE public."Promocion_Especial_id_promo_especial_seq";
       public          postgres    false    237            �           0    0 (   Promocion_Especial_id_promo_especial_seq    SEQUENCE OWNED BY     y   ALTER SEQUENCE public."Promocion_Especial_id_promo_especial_seq" OWNED BY public."Promocion_Especial".id_promo_especial;
          public          postgres    false    238            �            1259    24888     Promocion_Especial_id_usario_seq    SEQUENCE     �   CREATE SEQUENCE public."Promocion_Especial_id_usario_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 9   DROP SEQUENCE public."Promocion_Especial_id_usario_seq";
       public          postgres    false    237            �           0    0     Promocion_Especial_id_usario_seq    SEQUENCE OWNED BY     j   ALTER SEQUENCE public."Promocion_Especial_id_usario_seq" OWNED BY public."Promocion_Especial".id_usuario;
          public          postgres    false    239            �            1259    24889    Promocion_id_promo_seq    SEQUENCE     �   CREATE SEQUENCE public."Promocion_id_promo_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public."Promocion_id_promo_seq";
       public          postgres    false    236            �           0    0    Promocion_id_promo_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public."Promocion_id_promo_seq" OWNED BY public."Promocion".id_promo;
          public          postgres    false    240            �            1259    24890 	   Proveedor    TABLE     �  CREATE TABLE public."Proveedor" (
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
       public         heap    postgres    false    884            �            1259    24898    Proveedor_id_proveedor_seq    SEQUENCE     �   CREATE SEQUENCE public."Proveedor_id_proveedor_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public."Proveedor_id_proveedor_seq";
       public          postgres    false    241            �           0    0    Proveedor_id_proveedor_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public."Proveedor_id_proveedor_seq" OWNED BY public."Proveedor".id_proveedor;
          public          postgres    false    242            �            1259    24899    Usuario    TABLE     =  CREATE TABLE public."Usuario" (
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
       public         heap    postgres    false            �            1259    24904    Usuario_id_usuario_seq    SEQUENCE     �   CREATE SEQUENCE public."Usuario_id_usuario_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public."Usuario_id_usuario_seq";
       public          postgres    false    243            �           0    0    Usuario_id_usuario_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public."Usuario_id_usuario_seq" OWNED BY public."Usuario".id_usuario;
          public          postgres    false    244            �           2604    24905    Aplicacion id_producto    DEFAULT     �   ALTER TABLE ONLY public."Aplicacion" ALTER COLUMN id_producto SET DEFAULT nextval('public."Aplicacion_id_producto_seq"'::regclass);
 G   ALTER TABLE public."Aplicacion" ALTER COLUMN id_producto DROP DEFAULT;
       public          postgres    false    216    215            �           2604    24906    Aplicacion id_proveedor    DEFAULT     �   ALTER TABLE ONLY public."Aplicacion" ALTER COLUMN id_proveedor SET DEFAULT nextval('public."Aplicacion_id_proveedor_seq"'::regclass);
 H   ALTER TABLE public."Aplicacion" ALTER COLUMN id_proveedor DROP DEFAULT;
       public          postgres    false    217    215            �           2604    24907    Artista id_artista    DEFAULT     |   ALTER TABLE ONLY public."Artista" ALTER COLUMN id_artista SET DEFAULT nextval('public."Artista_id_artista_seq"'::regclass);
 C   ALTER TABLE public."Artista" ALTER COLUMN id_artista DROP DEFAULT;
       public          postgres    false    219    218            �           2604    24908    Cancion id_producto    DEFAULT     ~   ALTER TABLE ONLY public."Cancion" ALTER COLUMN id_producto SET DEFAULT nextval('public."Cancion_id_producto_seq"'::regclass);
 D   ALTER TABLE public."Cancion" ALTER COLUMN id_producto DROP DEFAULT;
       public          postgres    false    222    220            �           2604    24909    Cancion id_artista    DEFAULT     |   ALTER TABLE ONLY public."Cancion" ALTER COLUMN id_artista SET DEFAULT nextval('public."Cancion_id_artista_seq"'::regclass);
 C   ALTER TABLE public."Cancion" ALTER COLUMN id_artista DROP DEFAULT;
       public          postgres    false    221    220            �           2604    24910    Compra id_usuario    DEFAULT     z   ALTER TABLE ONLY public."Compra" ALTER COLUMN id_usuario SET DEFAULT nextval('public."Compra_id_usuario_seq"'::regclass);
 B   ALTER TABLE public."Compra" ALTER COLUMN id_usuario DROP DEFAULT;
       public          postgres    false    227    224            �           2604    24911    Compra id_producto    DEFAULT     |   ALTER TABLE ONLY public."Compra" ALTER COLUMN id_producto SET DEFAULT nextval('public."Compra_id_producto_seq"'::regclass);
 C   ALTER TABLE public."Compra" ALTER COLUMN id_producto DROP DEFAULT;
       public          postgres    false    225    224            �           2604    24912    Compra id_promo    DEFAULT     v   ALTER TABLE ONLY public."Compra" ALTER COLUMN id_promo SET DEFAULT nextval('public."Compra_id_promo_seq"'::regclass);
 @   ALTER TABLE public."Compra" ALTER COLUMN id_promo DROP DEFAULT;
       public          postgres    false    226    224            �           2604    24913    Dispositivo id_producto    DEFAULT     �   ALTER TABLE ONLY public."Dispositivo" ALTER COLUMN id_producto SET DEFAULT nextval('public."Dispositivo_id_producto_seq"'::regclass);
 H   ALTER TABLE public."Dispositivo" ALTER COLUMN id_producto DROP DEFAULT;
       public          postgres    false    231    228            �           2604    24914 "   Dispositivo_Aplicacion id_producto    DEFAULT     �   ALTER TABLE ONLY public."Dispositivo_Aplicacion" ALTER COLUMN id_producto SET DEFAULT nextval('public."Dispositivo_Aplicacion_id_producto_seq"'::regclass);
 S   ALTER TABLE public."Dispositivo_Aplicacion" ALTER COLUMN id_producto DROP DEFAULT;
       public          postgres    false    230    229            �           2604    24915    Paises_Promo id_promo    DEFAULT     �   ALTER TABLE ONLY public."Paises_Promo" ALTER COLUMN id_promo SET DEFAULT nextval('public."Paises_Promo_id_promo_seq"'::regclass);
 F   ALTER TABLE public."Paises_Promo" ALTER COLUMN id_promo DROP DEFAULT;
       public          postgres    false    233    232            �           2604    24916    Producto id_producto    DEFAULT     �   ALTER TABLE ONLY public."Producto" ALTER COLUMN id_producto SET DEFAULT nextval('public."Producto_id_producto_seq"'::regclass);
 E   ALTER TABLE public."Producto" ALTER COLUMN id_producto DROP DEFAULT;
       public          postgres    false    235    234            �           2604    24917    Promocion id_promo    DEFAULT     |   ALTER TABLE ONLY public."Promocion" ALTER COLUMN id_promo SET DEFAULT nextval('public."Promocion_id_promo_seq"'::regclass);
 C   ALTER TABLE public."Promocion" ALTER COLUMN id_promo DROP DEFAULT;
       public          postgres    false    240    236            �           2604    24918 $   Promocion_Especial id_promo_especial    DEFAULT     �   ALTER TABLE ONLY public."Promocion_Especial" ALTER COLUMN id_promo_especial SET DEFAULT nextval('public."Promocion_Especial_id_promo_especial_seq"'::regclass);
 U   ALTER TABLE public."Promocion_Especial" ALTER COLUMN id_promo_especial DROP DEFAULT;
       public          postgres    false    238    237            �           2604    24919    Promocion_Especial id_usuario    DEFAULT     �   ALTER TABLE ONLY public."Promocion_Especial" ALTER COLUMN id_usuario SET DEFAULT nextval('public."Promocion_Especial_id_usario_seq"'::regclass);
 N   ALTER TABLE public."Promocion_Especial" ALTER COLUMN id_usuario DROP DEFAULT;
       public          postgres    false    239    237            �           2604    24920    Proveedor id_proveedor    DEFAULT     �   ALTER TABLE ONLY public."Proveedor" ALTER COLUMN id_proveedor SET DEFAULT nextval('public."Proveedor_id_proveedor_seq"'::regclass);
 G   ALTER TABLE public."Proveedor" ALTER COLUMN id_proveedor DROP DEFAULT;
       public          postgres    false    242    241            �           2604    24921    Usuario id_usuario    DEFAULT     |   ALTER TABLE ONLY public."Usuario" ALTER COLUMN id_usuario SET DEFAULT nextval('public."Usuario_id_usuario_seq"'::regclass);
 C   ALTER TABLE public."Usuario" ALTER COLUMN id_usuario DROP DEFAULT;
       public          postgres    false    244    243            �          0    24814 
   Aplicacion 
   TABLE DATA           �   COPY public."Aplicacion" (id_producto, tamano_mb, version, nombre_aplicacion, descripcion, version_ios, tematica, id_proveedor) FROM stdin;
    public          postgres    false    215   �       �          0    24824    Artista 
   TABLE DATA           d   COPY public."Artista" (id_artista, nom_artistico, nombre_casa, fecha_inicio, fecha_fin) FROM stdin;
    public          postgres    false    218   ��       �          0    24832    Cancion 
   TABLE DATA           �   COPY public."Cancion" (id_producto, nom_cancion, fecha_lanz, duracion_cancion, genero, unidades_vendidas, nom_disco, id_artista) FROM stdin;
    public          postgres    false    220   ��       �          0    24840    Casa_Disquera 
   TABLE DATA           F   COPY public."Casa_Disquera" (nombre_casa, direccion_casa) FROM stdin;
    public          postgres    false    223   {�       �          0    24845    Compra 
   TABLE DATA           b   COPY public."Compra" (id_usuario, id_producto, fecha_compra, rating, monto, id_promo) FROM stdin;
    public          postgres    false    224   ��       �          0    24851    Dispositivo 
   TABLE DATA           `   COPY public."Dispositivo" (id_producto, modelo, generacion, version_ios, capacidad) FROM stdin;
    public          postgres    false    228   �       �          0    24859    Dispositivo_Aplicacion 
   TABLE DATA           W   COPY public."Dispositivo_Aplicacion" (id_producto, dispositivo_compatible) FROM stdin;
    public          postgres    false    229   ��       �          0    24866    Paises_Promo 
   TABLE DATA           8   COPY public."Paises_Promo" (id_promo, pais) FROM stdin;
    public          postgres    false    232   ��       �          0    24872    Producto 
   TABLE DATA           D   COPY public."Producto" (id_producto, costo, puntuacion) FROM stdin;
    public          postgres    false    234   ��       �          0    24879 	   Promocion 
   TABLE DATA           g   COPY public."Promocion" (id_promo, fecha_inicio, fecha_fin, duracion_promocion, descuento) FROM stdin;
    public          postgres    false    236   ;�       �          0    24884    Promocion_Especial 
   TABLE DATA           f   COPY public."Promocion_Especial" (id_promo_especial, fecha_inicio, fecha_fin, id_usuario) FROM stdin;
    public          postgres    false    237   ��       �          0    24890 	   Proveedor 
   TABLE DATA           �   COPY public."Proveedor" (id_proveedor, nombre_proveedor, correo_proveedor, direccion_proveedor, fecha_afiliacion, tipo_proveedor) FROM stdin;
    public          postgres    false    241   ��       �          0    24899    Usuario 
   TABLE DATA           �   COPY public."Usuario" (id_usuario, nombre_usuario, apellido_usuario, correo_usuario, ciudad_usuario, pais_usuario, fecha_venc, num_tdc, cod_vvt) FROM stdin;
    public          postgres    false    243   �       �           0    0    Aplicacion_id_producto_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public."Aplicacion_id_producto_seq"', 1, false);
          public          postgres    false    216            �           0    0    Aplicacion_id_proveedor_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public."Aplicacion_id_proveedor_seq"', 1, false);
          public          postgres    false    217            �           0    0    Artista_id_artista_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public."Artista_id_artista_seq"', 11, true);
          public          postgres    false    219            �           0    0    Cancion_id_artista_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public."Cancion_id_artista_seq"', 1, false);
          public          postgres    false    221            �           0    0    Cancion_id_producto_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public."Cancion_id_producto_seq"', 1, false);
          public          postgres    false    222            �           0    0    Compra_id_producto_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public."Compra_id_producto_seq"', 1, false);
          public          postgres    false    225            �           0    0    Compra_id_promo_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public."Compra_id_promo_seq"', 1, false);
          public          postgres    false    226            �           0    0    Compra_id_usuario_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public."Compra_id_usuario_seq"', 1, false);
          public          postgres    false    227            �           0    0 &   Dispositivo_Aplicacion_id_producto_seq    SEQUENCE SET     W   SELECT pg_catalog.setval('public."Dispositivo_Aplicacion_id_producto_seq"', 1, false);
          public          postgres    false    230            �           0    0    Dispositivo_id_producto_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public."Dispositivo_id_producto_seq"', 1, false);
          public          postgres    false    231            �           0    0    Paises_Promo_id_promo_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public."Paises_Promo_id_promo_seq"', 1, false);
          public          postgres    false    233            �           0    0    Producto_id_producto_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public."Producto_id_producto_seq"', 30, true);
          public          postgres    false    235            �           0    0 (   Promocion_Especial_id_promo_especial_seq    SEQUENCE SET     X   SELECT pg_catalog.setval('public."Promocion_Especial_id_promo_especial_seq"', 2, true);
          public          postgres    false    238            �           0    0     Promocion_Especial_id_usario_seq    SEQUENCE SET     Q   SELECT pg_catalog.setval('public."Promocion_Especial_id_usario_seq"', 1, false);
          public          postgres    false    239            �           0    0    Promocion_id_promo_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public."Promocion_id_promo_seq"', 10, true);
          public          postgres    false    240            �           0    0    Proveedor_id_proveedor_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public."Proveedor_id_proveedor_seq"', 11, true);
          public          postgres    false    242            �           0    0    Usuario_id_usuario_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public."Usuario_id_usuario_seq"', 10, true);
          public          postgres    false    244            �           2606    24923    Aplicacion Aplicacion_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public."Aplicacion"
    ADD CONSTRAINT "Aplicacion_pkey" PRIMARY KEY (id_producto);
 H   ALTER TABLE ONLY public."Aplicacion" DROP CONSTRAINT "Aplicacion_pkey";
       public            postgres    false    215            �           2606    24925    Artista Artista_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public."Artista"
    ADD CONSTRAINT "Artista_pkey" PRIMARY KEY (id_artista);
 B   ALTER TABLE ONLY public."Artista" DROP CONSTRAINT "Artista_pkey";
       public            postgres    false    218            �           2606    24927    Cancion Cancion_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public."Cancion"
    ADD CONSTRAINT "Cancion_pkey" PRIMARY KEY (id_producto);
 B   ALTER TABLE ONLY public."Cancion" DROP CONSTRAINT "Cancion_pkey";
       public            postgres    false    220            �           2606    24929     Casa_Disquera Casa_Disquera_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY public."Casa_Disquera"
    ADD CONSTRAINT "Casa_Disquera_pkey" PRIMARY KEY (nombre_casa);
 N   ALTER TABLE ONLY public."Casa_Disquera" DROP CONSTRAINT "Casa_Disquera_pkey";
       public            postgres    false    223            �           2606    24931    Compra Compra_pkey 
   CONSTRAINT     w   ALTER TABLE ONLY public."Compra"
    ADD CONSTRAINT "Compra_pkey" PRIMARY KEY (id_usuario, id_producto, fecha_compra);
 @   ALTER TABLE ONLY public."Compra" DROP CONSTRAINT "Compra_pkey";
       public            postgres    false    224    224    224            �           2606    24933 2   Dispositivo_Aplicacion Dispositivo_Aplicacion_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public."Dispositivo_Aplicacion"
    ADD CONSTRAINT "Dispositivo_Aplicacion_pkey" PRIMARY KEY (id_producto, dispositivo_compatible);
 `   ALTER TABLE ONLY public."Dispositivo_Aplicacion" DROP CONSTRAINT "Dispositivo_Aplicacion_pkey";
       public            postgres    false    229    229            �           2606    24935    Dispositivo Dispositivo_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY public."Dispositivo"
    ADD CONSTRAINT "Dispositivo_pkey" PRIMARY KEY (id_producto);
 J   ALTER TABLE ONLY public."Dispositivo" DROP CONSTRAINT "Dispositivo_pkey";
       public            postgres    false    228            �           2606    24937    Paises_Promo Paises_Promo_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public."Paises_Promo"
    ADD CONSTRAINT "Paises_Promo_pkey" PRIMARY KEY (id_promo, pais);
 L   ALTER TABLE ONLY public."Paises_Promo" DROP CONSTRAINT "Paises_Promo_pkey";
       public            postgres    false    232    232                       2606    24939    Producto Producto_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public."Producto"
    ADD CONSTRAINT "Producto_pkey" PRIMARY KEY (id_producto);
 D   ALTER TABLE ONLY public."Producto" DROP CONSTRAINT "Producto_pkey";
       public            postgres    false    234                       2606    24941 *   Promocion_Especial Promocion_Especial_pkey 
   CONSTRAINT     {   ALTER TABLE ONLY public."Promocion_Especial"
    ADD CONSTRAINT "Promocion_Especial_pkey" PRIMARY KEY (id_promo_especial);
 X   ALTER TABLE ONLY public."Promocion_Especial" DROP CONSTRAINT "Promocion_Especial_pkey";
       public            postgres    false    237                       2606    24943    Promocion Promocion_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public."Promocion"
    ADD CONSTRAINT "Promocion_pkey" PRIMARY KEY (id_promo);
 F   ALTER TABLE ONLY public."Promocion" DROP CONSTRAINT "Promocion_pkey";
       public            postgres    false    236                       2606    24945    Proveedor Proveedor_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public."Proveedor"
    ADD CONSTRAINT "Proveedor_pkey" PRIMARY KEY (id_proveedor);
 F   ALTER TABLE ONLY public."Proveedor" DROP CONSTRAINT "Proveedor_pkey";
       public            postgres    false    241                       2606    24947    Usuario Usuario_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public."Usuario"
    ADD CONSTRAINT "Usuario_pkey" PRIMARY KEY (id_usuario);
 B   ALTER TABLE ONLY public."Usuario" DROP CONSTRAINT "Usuario_pkey";
       public            postgres    false    243            �           2606    24948    Usuario check_cod_vvt    CHECK CONSTRAINT     z   ALTER TABLE public."Usuario"
    ADD CONSTRAINT check_cod_vvt CHECK (((cod_vvt >= 100) AND (cod_vvt <= 9999))) NOT VALID;
 <   ALTER TABLE public."Usuario" DROP CONSTRAINT check_cod_vvt;
       public          postgres    false    243    243            �           2606    24949    Usuario check_correo_format    CHECK CONSTRAINT     �   ALTER TABLE public."Usuario"
    ADD CONSTRAINT check_correo_format CHECK ((correo_usuario ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'::text)) NOT VALID;
 B   ALTER TABLE public."Usuario" DROP CONSTRAINT check_correo_format;
       public          postgres    false    243    243                       2606    24951    Usuario check_correo_unico 
   CONSTRAINT     t   ALTER TABLE ONLY public."Usuario"
    ADD CONSTRAINT check_correo_unico UNIQUE NULLS NOT DISTINCT (correo_usuario);
 F   ALTER TABLE ONLY public."Usuario" DROP CONSTRAINT check_correo_unico;
       public            postgres    false    243            	           2606    24953    Proveedor check_correo_unique 
   CONSTRAINT     y   ALTER TABLE ONLY public."Proveedor"
    ADD CONSTRAINT check_correo_unique UNIQUE NULLS NOT DISTINCT (correo_proveedor);
 I   ALTER TABLE ONLY public."Proveedor" DROP CONSTRAINT check_correo_unique;
       public            postgres    false    241            �           2606    24954    Cancion check_duracion    CHECK CONSTRAINT     i   ALTER TABLE public."Cancion"
    ADD CONSTRAINT check_duracion CHECK ((duracion_cancion > 0)) NOT VALID;
 =   ALTER TABLE public."Cancion" DROP CONSTRAINT check_duracion;
       public          postgres    false    220    220            �           2606    24955    Usuario check_fecha    CHECK CONSTRAINT     l   ALTER TABLE public."Usuario"
    ADD CONSTRAINT check_fecha CHECK ((fecha_venc >= CURRENT_DATE)) NOT VALID;
 :   ALTER TABLE public."Usuario" DROP CONSTRAINT check_fecha;
       public          postgres    false    243    243            �           2606    24956    Compra check_fecha    CHECK CONSTRAINT     m   ALTER TABLE public."Compra"
    ADD CONSTRAINT check_fecha CHECK ((fecha_compra <= CURRENT_DATE)) NOT VALID;
 9   ALTER TABLE public."Compra" DROP CONSTRAINT check_fecha;
       public          postgres    false    224    224            �           2606    24957    Usuario check_num_tdc    CHECK CONSTRAINT     �   ALTER TABLE public."Usuario"
    ADD CONSTRAINT check_num_tdc CHECK (((num_tdc >= '100000000000000'::bigint) AND (num_tdc <= '9999999999999999'::bigint))) NOT VALID;
 <   ALTER TABLE public."Usuario" DROP CONSTRAINT check_num_tdc;
       public          postgres    false    243    243            �           2606    24958    Compra check_rating    CHECK CONSTRAINT     q   ALTER TABLE public."Compra"
    ADD CONSTRAINT check_rating CHECK (((rating >= 0) AND (rating <= 5))) NOT VALID;
 :   ALTER TABLE public."Compra" DROP CONSTRAINT check_rating;
       public          postgres    false    224    224            �           2606    24959    Cancion check_unidades    CHECK CONSTRAINT     k   ALTER TABLE public."Cancion"
    ADD CONSTRAINT check_unidades CHECK ((unidades_vendidas >= 0)) NOT VALID;
 =   ALTER TABLE public."Cancion" DROP CONSTRAINT check_unidades;
       public          postgres    false    220    220                       2620    24960    Compra trigger_cancion_vendida    TRIGGER     �   CREATE TRIGGER trigger_cancion_vendida AFTER INSERT OR UPDATE OF id_producto ON public."Compra" FOR EACH ROW EXECUTE FUNCTION public.contar_unidades_vendidas();
 9   DROP TRIGGER trigger_cancion_vendida ON public."Compra";
       public          postgres    false    248    224    224                       2620    24961 !   Compra trigger_compatibilidad_app    TRIGGER     �   CREATE TRIGGER trigger_compatibilidad_app BEFORE INSERT OR UPDATE OF id_producto ON public."Compra" FOR EACH ROW EXECUTE FUNCTION public.verificar_compatibilidad();
 <   DROP TRIGGER trigger_compatibilidad_app ON public."Compra";
       public          postgres    false    224    224    261                       2620    24962     Promocion trigger_duracion_promo    TRIGGER     �   CREATE TRIGGER trigger_duracion_promo BEFORE INSERT OR UPDATE OF fecha_inicio, fecha_fin ON public."Promocion" FOR EACH ROW EXECUTE FUNCTION public.calcular_duracion();
 ;   DROP TRIGGER trigger_duracion_promo ON public."Promocion";
       public          postgres    false    236    236    245    236                        2620    24963 $   Promocion_Especial trigger_fecha_fin    TRIGGER     �   CREATE TRIGGER trigger_fecha_fin BEFORE INSERT OR UPDATE OF fecha_inicio ON public."Promocion_Especial" FOR EACH ROW EXECUTE FUNCTION public.calcular_fecha_fin_pe();
 ?   DROP TRIGGER trigger_fecha_fin ON public."Promocion_Especial";
       public          postgres    false    237    237    246                       2620    24964    Compra trigger_promo_especial    TRIGGER     �   CREATE TRIGGER trigger_promo_especial AFTER INSERT OR UPDATE OF fecha_compra ON public."Compra" FOR EACH ROW EXECUTE FUNCTION public.crear_promo_especial();
 8   DROP TRIGGER trigger_promo_especial ON public."Compra";
       public          postgres    false    249    224    224                       2620    24965    Compra trigger_promocion    TRIGGER     z   CREATE TRIGGER trigger_promocion BEFORE INSERT ON public."Compra" FOR EACH ROW EXECUTE FUNCTION public.verificar_promo();
 3   DROP TRIGGER trigger_promocion ON public."Compra";
       public          postgres    false    262    224                       2620    24966 "   Compra trigger_puntuacion_promedio    TRIGGER     �   CREATE TRIGGER trigger_puntuacion_promedio AFTER INSERT OR UPDATE OF rating, id_producto ON public."Compra" FOR EACH ROW EXECUTE FUNCTION public.calcular_promedio_puntuacion();
 =   DROP TRIGGER trigger_puntuacion_promedio ON public."Compra";
       public          postgres    false    224    247    224    224                       2606    24967 !   Aplicacion Aplicacion_Producto_FK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Aplicacion"
    ADD CONSTRAINT "Aplicacion_Producto_FK" FOREIGN KEY (id_producto) REFERENCES public."Producto"(id_producto) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 O   ALTER TABLE ONLY public."Aplicacion" DROP CONSTRAINT "Aplicacion_Producto_FK";
       public          postgres    false    234    3585    215                       2606    24972 "   Aplicacion Aplicacion_Proveedor_FK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Aplicacion"
    ADD CONSTRAINT "Aplicacion_Proveedor_FK" FOREIGN KEY (id_proveedor) REFERENCES public."Proveedor"(id_proveedor);
 P   ALTER TABLE ONLY public."Aplicacion" DROP CONSTRAINT "Aplicacion_Proveedor_FK";
       public          postgres    false    241    215    3591                       2606    24977    Artista Artista_DisqueraFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Artista"
    ADD CONSTRAINT "Artista_DisqueraFK" FOREIGN KEY (nombre_casa) REFERENCES public."Casa_Disquera"(nombre_casa) ON UPDATE CASCADE ON DELETE SET DEFAULT;
 H   ALTER TABLE ONLY public."Artista" DROP CONSTRAINT "Artista_DisqueraFK";
       public          postgres    false    3575    223    218                       2606    24982    Cancion Cancion_ArtistaFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Cancion"
    ADD CONSTRAINT "Cancion_ArtistaFK" FOREIGN KEY (id_artista) REFERENCES public."Artista"(id_artista) ON UPDATE CASCADE;
 G   ALTER TABLE ONLY public."Cancion" DROP CONSTRAINT "Cancion_ArtistaFK";
       public          postgres    false    218    220    3571                       2606    24987    Cancion Cancion_ProductoFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Cancion"
    ADD CONSTRAINT "Cancion_ProductoFK" FOREIGN KEY (id_producto) REFERENCES public."Producto"(id_producto) ON UPDATE CASCADE ON DELETE CASCADE;
 H   ALTER TABLE ONLY public."Cancion" DROP CONSTRAINT "Cancion_ProductoFK";
       public          postgres    false    3585    234    220                       2606    24992    Compra Compra_ProductoFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Compra"
    ADD CONSTRAINT "Compra_ProductoFK" FOREIGN KEY (id_producto) REFERENCES public."Producto"(id_producto) ON UPDATE CASCADE;
 F   ALTER TABLE ONLY public."Compra" DROP CONSTRAINT "Compra_ProductoFK";
       public          postgres    false    224    234    3585                       2606    25002    Compra Compra_PromocionFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Compra"
    ADD CONSTRAINT "Compra_PromocionFK" FOREIGN KEY (id_promo) REFERENCES public."Promocion"(id_promo) NOT VALID;
 G   ALTER TABLE ONLY public."Compra" DROP CONSTRAINT "Compra_PromocionFK";
       public          postgres    false    236    224    3587                       2606    25007    Compra Compra_UsuarioFk    FK CONSTRAINT     �   ALTER TABLE ONLY public."Compra"
    ADD CONSTRAINT "Compra_UsuarioFk" FOREIGN KEY (id_usuario) REFERENCES public."Usuario"(id_usuario) ON UPDATE CASCADE;
 E   ALTER TABLE ONLY public."Compra" DROP CONSTRAINT "Compra_UsuarioFk";
       public          postgres    false    243    3595    224                       2606    25012 /   Dispositivo_Aplicacion Dispositivo_AplicacionFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Dispositivo_Aplicacion"
    ADD CONSTRAINT "Dispositivo_AplicacionFK" FOREIGN KEY (id_producto) REFERENCES public."Aplicacion"(id_producto) ON UPDATE CASCADE ON DELETE CASCADE;
 ]   ALTER TABLE ONLY public."Dispositivo_Aplicacion" DROP CONSTRAINT "Dispositivo_AplicacionFK";
       public          postgres    false    229    215    3569                       2606    25017 "   Dispositivo Dispositivo_ProductoFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Dispositivo"
    ADD CONSTRAINT "Dispositivo_ProductoFK" FOREIGN KEY (id_producto) REFERENCES public."Producto"(id_producto) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 P   ALTER TABLE ONLY public."Dispositivo" DROP CONSTRAINT "Dispositivo_ProductoFK";
       public          postgres    false    228    3585    234                       2606    25022    Paises_Promo Pais_PromoFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Paises_Promo"
    ADD CONSTRAINT "Pais_PromoFK" FOREIGN KEY (id_promo) REFERENCES public."Promocion"(id_promo) ON UPDATE CASCADE ON DELETE CASCADE;
 G   ALTER TABLE ONLY public."Paises_Promo" DROP CONSTRAINT "Pais_PromoFK";
       public          postgres    false    232    236    3587                       2606    25027 #   Promocion_Especial Promo_Usuario_FK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Promocion_Especial"
    ADD CONSTRAINT "Promo_Usuario_FK" FOREIGN KEY (id_usuario) REFERENCES public."Usuario"(id_usuario) ON UPDATE CASCADE ON DELETE CASCADE;
 Q   ALTER TABLE ONLY public."Promocion_Especial" DROP CONSTRAINT "Promo_Usuario_FK";
       public          postgres    false    243    3595    237            �   �  x��TAn�0<�^����d;��A[�I�����Ä"�
����^��<!?�K���*�"� q	rwvvFJ�:-@�j��I^(87�u��4��#�o[�z�7�߷�'/l|�GL�\������P�d�[���ԟL����$� �&��Pf���B�%ل�q�M��8`Rc�&m��\�f�1ց5'�����^GPd��re��55��^�6�99�J���;�R�6��aK�<J�*'�KhM��+oIڭ�@�����k�QP��b>�=B9X�r�g���&�̫��ƥ���R[�KT<�Z/�bK�Ȃ�$�n��;���/JА`���õ�UfkY޳iY�6L35��T0�'���w���w�Vf�����L�Cq��
�,�ʈ|
f���rE���ל��R�9���|0�
��j��L���H!xk��ۀ~s�\Q-M.FE�3u
�R\Qt��??E��9�+�+�	���X��i�%'n`�O�?��$�NF֡�1�����n+�<�s�)��f���W芬�{~�#="ڵ�R��cGS�G�]�l
Ť����U��-��e�o:ݵ��{m
e�}Da�$Q#��O�F%(��T�igy#�W�PQ��O>л����O^����J�n^����{��<��G�e�_+~�f      �     x�m�Mn�0FדS��<�@��OT�� ���f����ȎU�H=G/V����x�g�%Gkο?��M��4�#���xȕʥ�KU�g>���,�W��u�����܆S��V�d/"��	ԟ��AmM���1������ �*m+��^(`q��j�}UI���ցċn	��v������l!U14�a��b]�c�8�a,z��gr.����ь��{,�&C�.����d��
v�wڈ��;X�U��6��|�僁�Ƌ�8Z�z6��8VeqGߟ�,�HJ�9      �   �  x�5�MN�0���S�R�N�$K��W$
� �q�!��ڕ〺{�x��$�i��F����9�4Q�,�l�:˛L5�T�䏐�ڻ��v����^w�;��~y�;�1��rYey�IJ]���/�d��zo;�8��y9�d]�c���p��@��|E�3�����ָ�f�*S���g���:)�H��\���F�H)*x^�.��"�3Y�Z���_r�5��k	_��1�,R*U��V3r��Μ���n:�J4�����q�<�L鮵՝ftk:�s_B�kד�N͞��Os)2SǼ�=Y=F��t`�"K�)��tD}�`Z����xz:�I-A�E^�{{����~
��#ޥ����_d�?	l��!�Tm��      �     x����j�@�����e�.S+�R{a�E�f4S�t�	�ŷo !��{77ߙ��#9��7;�wRW��Z�L�8,�#qM	�a!lv��,���a�"��s1�@.��q�t,��s��kq�͵��R�f��cr_D�4�['X���9m�<�ƭ���W�k�V&���ƙ�g�EpD!�G��,���ғ��Wx�C��hҴ�����v�MR�3�_T�Q�*�>l�\֨����-<�.��������a�YvŰ��8�? .n�      �   W   x�=��� ��.�8!�,�	��!U��|v���l\��B��[�S��gb� ��^�)�fQfSk�E�}K�#�׋�[�."�z      �   �   x�U�M
�@F��)rq�t�.
�"-�����h=~�o���%a�lB�H1��F�t��@e�0٠��6�!ﺗ�{�y6tq�wY������UM����226��#�d$���d�P��,��@Q}A� 3����	�·~UdW/g�7���<"D��)=Z      �      x������ � �      �   �   x�]��jA�����'(Z{��,���(��kX���H��7#ū|g����!�!Շ��V�@��aGJ}��� �a}��>k�X�(�>Y�7s �³��Rh�(\`-�Ί�3x�SԢ�1U�{6�߷��+�H���@��	[�=�~/�6��p	u���?]J,�-�/���y���S�z1J�Y��z���]\c]���~@�?��g      �   s   x�E���0E��G1�Y��D*H�uL&`�ő@A���ܤ%+��,����
dSᛧ�}s�7�^��Ф4�&c��z��IM��zH8��(V��/��1�;%q|�Ǳ�s���5�      �   �   x�]�A!��&4����c%�fomWl
ME�e�����E48��i����7'���(t�|)��0Y:#jzE�:��*���y�y9E-��'��U3�Q�8�yڶX�{ko�_���g��������G�}."z �3�      �      x������ � �      �     x�eR]n�@~^N1����7BB$h�y���ޘ	�]kwM���&�XǦP�J^kv������X�.�k���q���e�������h���z��d�,���~(FQ�Q̟XV���ؘw�%l}S�q"7�c��U���	l���hT�~m����*�8��8�V#sB���hܟ���&���3j������[��K�`mr���6�xdLk�RX;�-���𢽴̜NR�SI������� v�*������U��?w&�;S�Bᚺ6��Y�7u��tg⍦�j2PH�׵B�^�r�Gϙ8	�i'7�ē�Z���H�����n7"���C�$��gVJ���%�ڄJ�d;6��摦��#m]�����x4�����Z\�웄�P �$�ƪ�ͦL��-�ؙ��ws�
��t0����O;;<�;G�3KRIX�m�"Q��G�rg����I��>1b��Ao�ű�6���T���t�2�r����tk�u>m��`0���!�      �     x����j�0����h�4�{��B ��i�Ћ֫��J�d6O�Yo�P�������7c�t�a:@�����C?�y���r�i�pR��\j&����+��s'" �FB�v%�^b	ʲ��B	}��3��:�q1��+��uF��#�*�]���~�9���E��B�wއ���u
�\?�HmoUK�8!��V9MY�F��7
n���]��	���g���zJ=��AŸeB�5N	��	���#��F�M�5�ݐ���o��ymߎ��y������75W�8i����1D�����+��|�c"�v(�B[�1MCZ��L*Ш-���JHp�6����޷��ؗE������M�X�$������2R;�|��&B"��P���|�{y�v�>�m�W�G�9��l#�6
(h<<�|�.�-!�(�K����]�'h�:�0.�"g|hC4��\)<������By
'�~���Eų�����-X��;��y�%M�!
�7M����     