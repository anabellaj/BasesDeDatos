PGDMP      3            
    {         
   Proyecto 2    16.1    16.1 �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    25702 
   Proyecto 2    DATABASE     �   CREATE DATABASE "Proyecto 2" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United States.1252';
    DROP DATABASE "Proyecto 2";
                postgres    false            r           1247    25704    Genero    DOMAIN     �   CREATE DOMAIN public."Genero" AS text
	CONSTRAINT check_domain CHECK ((VALUE = ANY (ARRAY['Pop'::text, 'Rock'::text, 'Balada'::text, 'Electronica'::text, 'Punk'::text, 'Otro'::text])));
    DROP DOMAIN public."Genero";
       public          postgres    false            v           1247    25707    Tematica    DOMAIN     �   CREATE DOMAIN public."Tematica" AS text
	CONSTRAINT check_domain CHECK ((VALUE = ANY (ARRAY['juegos'::text, 'cocina'::text, 'lectura'::text, 'otro'::text])));
    DROP DOMAIN public."Tematica";
       public          postgres    false            z           1247    25710    Tipo_Proveedor    DOMAIN     �   CREATE DOMAIN public."Tipo_Proveedor" AS text
	CONSTRAINT check_domain CHECK ((VALUE = ANY (ARRAY['Desarrollador'::text, 'Empresa'::text])));
 %   DROP DOMAIN public."Tipo_Proveedor";
       public          postgres    false            �            1255    25712    calcular_duracion()    FUNCTION     �   CREATE FUNCTION public.calcular_duracion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN 
	NEW.duracion_promocion =  NEW.fecha_fin- NEW.fecha_inicio;
	RETURN NEW;
END;
$$;
 *   DROP FUNCTION public.calcular_duracion();
       public          postgres    false            �            1255    25713    calcular_fecha_fin_pe()    FUNCTION     �   CREATE FUNCTION public.calcular_fecha_fin_pe() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
	NEW.fecha_fin = NEW.fecha_inicio + interval '1 month';
	RETURN NEW;
END;
	$$;
 .   DROP FUNCTION public.calcular_fecha_fin_pe();
       public          postgres    false            �            1255    25714    calcular_promedio_puntuacion()    FUNCTION     ]  CREATE FUNCTION public.calcular_promedio_puntuacion() RETURNS trigger
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
       public          postgres    false            �            1255    25715    contar_unidades_vendidas()    FUNCTION     4  CREATE FUNCTION public.contar_unidades_vendidas() RETURNS trigger
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
       public          postgres    false            �            1255    25716    crear_promo_especial()    FUNCTION     F  CREATE FUNCTION public.crear_promo_especial() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE contador integer;

BEGIN

	SELECT count("C".id_producto)
	INTO contador
	FROM public."Compra" AS "C"
	WHERE NEW.fecha_compra = "C".fecha_compra;
	
	IF contador > 3 AND NOT(EXISTS (SELECT "PE".id_usuario 
									FROM public."Promocion_Especial" AS "PE" 
									WHERE NEW.id_usuario = "PE".id_usuario AND "PE".fecha_fin > NEW.fecha_compra )) THEN
		INSERT INTO public."Promocion_Especial"
		VALUES (DEFAULT, NEW.fecha_compra, null, NEW.id_usuario);

	END IF;
	RETURN NEW;
END;$$;
 -   DROP FUNCTION public.crear_promo_especial();
       public          postgres    false                       1255    25967    ver_dispositivos_mas_ios()    FUNCTION     F  CREATE FUNCTION public.ver_dispositivos_mas_ios() RETURNS smallint
    LANGUAGE plpgsql
    AS $$
DECLARE version_nueva smallint;
DECLARE version_disp text[];
DECLARE max_version text[];
DECLARE D record;

BEGIN
	
	FOR D IN (SELECT Dis.version_ios
			 FROM public."Dispositivo" AS Dis)
	LOOP
		version_disp = string_to_array(D.version_ios, '.');
		FOR V IN  1..array_length(version_disp,1) LOOP
			RAISE NOTICE 'Version disp%', version_disp[V];
			RAISE NOTICE 'Version max%', max_version[V];
			CONTINUE WHEN CAST(version_disp[V] AS integer) = CAST(max_version[V] AS integer);
			EXIT WHEN CAST(version_disp[V] AS integer) < CAST(max_version[V] AS integer);
			IF CAST(version_disp[V] AS integer) > CAST(max_version[V] AS integer) OR max_version[V] IS null THEN
							max_version = version_disp;  
							RAISE NOTICE 'La nueva version max %', max_version;
			END IF;
			
		END LOOP;
	END LOOP;
RAISE NOTICE 'La  version max %', max_version;

version_nueva = CAST(ARRAY_TO_STRING(max_version, '') AS smallint );
RAISE NOTICE 'version nueva %', version_nueva;

RETURN version_nueva;
END; 
$$;
 1   DROP FUNCTION public.ver_dispositivos_mas_ios();
       public          postgres    false                       1255    25717    verificar_compatibilidad()    FUNCTION     R  CREATE FUNCTION public.verificar_compatibilidad() RETURNS trigger
    LANGUAGE plpgsql
    AS $$DECLARE version_ios_app text[];
DECLARE version_ios_disp text[];
DECLARE compatible boolean := false;
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
				  WHERE "C".id_usuario = NEW.id_usuario AND "D".modelo IN (SELECT "DA".dispositivo_compatible
				 															FROM public."Dispositivo_Aplicacion" AS "DA"
				 															WHERE NEW.id_producto = "DA".id_producto))
		LOOP
			version_ios_disp = string_to_array(D.version_ios,'.');
			IF array_length(version_ios_app, 1)< array_length(version_ios_disp,1)THEN
				FOR V IN 1..array_length(version_ios_app,1) LOOP
						IF CAST(version_ios_app[V] AS integer) < CAST(version_ios_disp[V] AS integer) THEN
							compatible = true;  
					END IF;
				END LOOP;
			ELSE
				FOR V IN 1..array_length(version_ios_disp,1) LOOP
						IF CAST(version_ios_app[V] AS integer) < CAST(version_ios_disp[V] AS integer) THEN
							compatible = true;  
					END IF;
				END LOOP;
			END IF;
		END LOOP; 

	IF compatible = false THEN 

		RAISE EXCEPTION 'Dispositivos Comprados y Aplicacion No Compatibles';
	ELSE
		RETURN NEW;
	END IF;
ELSE
RETURN NEW;
END IF;

END;

			
		$$;
 1   DROP FUNCTION public.verificar_compatibilidad();
       public          postgres    false            
           1255    25718    verificar_promo()    FUNCTION     �  CREATE FUNCTION public.verificar_promo() RETURNS trigger
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
		WHERE "P".pais = pais_selec AND (NEW.fecha_compra BETWEEN "PR".fecha_inicio AND "PR".fecha_fin) AND "PR".descuento = (SELECT MAX(P.descuento) 
																															FROM public."Promocion" AS P JOIN public."Paises_Promo" PP
																															 ON P.id_promo = PP.id_promo
																															 WHERE PP.pais = pais_selec);	
	ELSE 
		NEW.id_promo_especial = id_promo_aplica;
		descu = 30;																														  
	END IF;
	
	IF id_promo_aplica IS NULL THEN
	NEW.monto = precio;
	ELSE 
		IF NEW.id_promo_especial IS NULL THEN
			NEW.id_promo = id_promo_aplica;
		END IF;
	NEW.monto = precio - (precio*descu/100);
	END IF;
	RETURN NEW;
END;$$;
 (   DROP FUNCTION public.verificar_promo();
       public          postgres    false            �            1259    25719 
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
       public         heap    postgres    false    886            �            1259    25727    Aplicacion_id_producto_seq    SEQUENCE     �   CREATE SEQUENCE public."Aplicacion_id_producto_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public."Aplicacion_id_producto_seq";
       public          postgres    false    215            �           0    0    Aplicacion_id_producto_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public."Aplicacion_id_producto_seq" OWNED BY public."Aplicacion".id_producto;
          public          postgres    false    216            �            1259    25728    Aplicacion_id_proveedor_seq    SEQUENCE     �   CREATE SEQUENCE public."Aplicacion_id_proveedor_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public."Aplicacion_id_proveedor_seq";
       public          postgres    false    215            �           0    0    Aplicacion_id_proveedor_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public."Aplicacion_id_proveedor_seq" OWNED BY public."Aplicacion".id_proveedor;
          public          postgres    false    217            �            1259    25729    Artista    TABLE       CREATE TABLE public."Artista" (
    id_artista bigint NOT NULL,
    nom_artistico text NOT NULL,
    nombre_casa text DEFAULT 'Independiente'::text,
    fecha_inicio date,
    fecha_fin date,
    CONSTRAINT check_fecha CHECK ((fecha_inicio < fecha_fin))
);
    DROP TABLE public."Artista";
       public         heap    postgres    false            �            1259    25736    Artista_id_artista_seq    SEQUENCE     �   CREATE SEQUENCE public."Artista_id_artista_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public."Artista_id_artista_seq";
       public          postgres    false    218            �           0    0    Artista_id_artista_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public."Artista_id_artista_seq" OWNED BY public."Artista".id_artista;
          public          postgres    false    219            �            1259    25737    Cancion    TABLE     2  CREATE TABLE public."Cancion" (
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
       public         heap    postgres    false    882            �            1259    25743    Cancion_id_artista_seq    SEQUENCE     �   CREATE SEQUENCE public."Cancion_id_artista_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public."Cancion_id_artista_seq";
       public          postgres    false    220            �           0    0    Cancion_id_artista_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public."Cancion_id_artista_seq" OWNED BY public."Cancion".id_artista;
          public          postgres    false    221            �            1259    25744    Cancion_id_producto_seq    SEQUENCE     �   CREATE SEQUENCE public."Cancion_id_producto_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 0   DROP SEQUENCE public."Cancion_id_producto_seq";
       public          postgres    false    220            �           0    0    Cancion_id_producto_seq    SEQUENCE OWNED BY     W   ALTER SEQUENCE public."Cancion_id_producto_seq" OWNED BY public."Cancion".id_producto;
          public          postgres    false    222            �            1259    25745    Casa_Disquera    TABLE     `   CREATE TABLE public."Casa_Disquera" (
    nombre_casa text NOT NULL,
    direccion_casa text
);
 #   DROP TABLE public."Casa_Disquera";
       public         heap    postgres    false            �            1259    25750    Compra    TABLE     �   CREATE TABLE public."Compra" (
    id_usuario bigint NOT NULL,
    id_producto bigint NOT NULL,
    fecha_compra date NOT NULL,
    rating smallint NOT NULL,
    monto real,
    id_promo bigint,
    id_promo_especial bigint
);
    DROP TABLE public."Compra";
       public         heap    postgres    false            �            1259    25753    Compra_id_producto_seq    SEQUENCE     �   CREATE SEQUENCE public."Compra_id_producto_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public."Compra_id_producto_seq";
       public          postgres    false    224            �           0    0    Compra_id_producto_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public."Compra_id_producto_seq" OWNED BY public."Compra".id_producto;
          public          postgres    false    225            �            1259    25754    Compra_id_promo_seq    SEQUENCE     ~   CREATE SEQUENCE public."Compra_id_promo_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ,   DROP SEQUENCE public."Compra_id_promo_seq";
       public          postgres    false    224            �           0    0    Compra_id_promo_seq    SEQUENCE OWNED BY     O   ALTER SEQUENCE public."Compra_id_promo_seq" OWNED BY public."Compra".id_promo;
          public          postgres    false    226            �            1259    25755    Compra_id_usuario_seq    SEQUENCE     �   CREATE SEQUENCE public."Compra_id_usuario_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public."Compra_id_usuario_seq";
       public          postgres    false    224            �           0    0    Compra_id_usuario_seq    SEQUENCE OWNED BY     S   ALTER SEQUENCE public."Compra_id_usuario_seq" OWNED BY public."Compra".id_usuario;
          public          postgres    false    227            �            1259    25756 	   Proveedor    TABLE     �  CREATE TABLE public."Proveedor" (
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
       public         heap    postgres    false    890            �            1259    25764 	   Consulta1    VIEW     W  CREATE VIEW public."Consulta1" AS
 SELECT id_proveedor,
    nombre_proveedor,
    tipo_proveedor
   FROM public."Proveedor"
  WHERE (id_proveedor IN ( SELECT "Aplicacion".id_proveedor
           FROM public."Aplicacion"
          GROUP BY "Aplicacion".id_proveedor
          ORDER BY (count("Aplicacion".id_producto)) DESC
         LIMIT 1));
    DROP VIEW public."Consulta1";
       public          postgres    false    215    215    228    228    228    890            �            1259    25768    Usuario    TABLE     =  CREATE TABLE public."Usuario" (
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
       public         heap    postgres    false            �            1259    25773 	   Consulta2    VIEW     -  CREATE VIEW public."Consulta2" AS
 SELECT "U".num_tdc,
    count("C".id_usuario) AS "Numero de Compras"
   FROM (public."Usuario" "U"
     JOIN public."Compra" "C" ON (("U".id_usuario = "C".id_usuario)))
  WHERE ("U".fecha_venc < ( SELECT (CURRENT_DATE + '3 mons'::interval)))
  GROUP BY "U".num_tdc;
    DROP VIEW public."Consulta2";
       public          postgres    false    224    230    230    230            �            1259    25778 	   Consulta3    VIEW     �  CREATE VIEW public."Consulta3" AS
 SELECT "U".id_usuario,
    "U".nombre_usuario,
    "U".correo_usuario
   FROM public."Usuario" "U"
  WHERE ("U".id_usuario IN ( SELECT "C".id_usuario
           FROM (public."Compra" "C"
             JOIN public."Aplicacion" "A" ON (("C".id_producto = "A".id_producto)))
          WHERE (("A".tematica)::text = 'cocina'::text)))
INTERSECT
 SELECT "U".id_usuario,
    "U".nombre_usuario,
    "U".correo_usuario
   FROM public."Usuario" "U"
  WHERE ("U".id_usuario IN ( SELECT "C".id_usuario
           FROM (public."Compra" "C"
             JOIN public."Cancion" "CA" ON (("C".id_producto = "CA".id_producto)))
          WHERE (("CA".genero)::text = 'Electronica'::text)));
    DROP VIEW public."Consulta3";
       public          postgres    false    215    215    220    220    224    224    230    230    230            �            1259    25783    Dispositivo    TABLE     �  CREATE TABLE public."Dispositivo" (
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
       public         heap    postgres    false            �            1259    25791    Dispositivo_Aplicacion    TABLE     |   CREATE TABLE public."Dispositivo_Aplicacion" (
    id_producto bigint NOT NULL,
    dispositivo_compatible text NOT NULL
);
 ,   DROP TABLE public."Dispositivo_Aplicacion";
       public         heap    postgres    false            �            1259    25796    Producto    TABLE     ;  CREATE TABLE public."Producto" (
    id_producto bigint NOT NULL,
    costo real NOT NULL,
    puntuacion real DEFAULT 0,
    CONSTRAINT check_costo CHECK ((costo > (0)::double precision)),
    CONSTRAINT check_puntuacion CHECK (((puntuacion >= (0)::double precision) AND (puntuacion <= (5)::double precision)))
);
    DROP TABLE public."Producto";
       public         heap    postgres    false            �            1259    25983 	   Consulta4    VIEW     V  CREATE VIEW public."Consulta4" AS
 SELECT a.id_producto,
    a.nombre_aplicacion
   FROM (public."Aplicacion" a
     JOIN public."Producto" p ON ((a.id_producto = p.id_producto)))
  WHERE ((a.id_producto IN ( SELECT da.id_producto
           FROM public."Dispositivo_Aplicacion" da
          WHERE (da.dispositivo_compatible IN ( SELECT d.modelo
                   FROM public."Dispositivo" d
                  WHERE ((replace(d.version_ios, '.'::text, ''::text))::smallint = ( SELECT public.ver_dispositivos_mas_ios() AS ver_dispositivos_mas_ios)))))) AND (p.puntuacion > (4)::double precision));
    DROP VIEW public."Consulta4";
       public          postgres    false    234    234    235    235    268    215    215    233    233            �            1259    25807 	   Consulta5    VIEW     �  CREATE VIEW public."Consulta5" AS
 SELECT a.nombre_casa,
    max(c.unidades_vendidas) AS max
   FROM (public."Artista" a
     JOIN public."Cancion" c ON ((a.id_artista = c.id_artista)))
  WHERE (a.nombre_casa IN ( SELECT a_1.nombre_casa
           FROM public."Artista" a_1
          GROUP BY a_1.nombre_casa
         HAVING (count(a_1.id_artista) >= 3)))
  GROUP BY a.nombre_casa
  ORDER BY (count(a.id_artista));
    DROP VIEW public."Consulta5";
       public          postgres    false    218    218    220    220            �            1259    25812 &   Dispositivo_Aplicacion_id_producto_seq    SEQUENCE     �   CREATE SEQUENCE public."Dispositivo_Aplicacion_id_producto_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 ?   DROP SEQUENCE public."Dispositivo_Aplicacion_id_producto_seq";
       public          postgres    false    234            �           0    0 &   Dispositivo_Aplicacion_id_producto_seq    SEQUENCE OWNED BY     u   ALTER SEQUENCE public."Dispositivo_Aplicacion_id_producto_seq" OWNED BY public."Dispositivo_Aplicacion".id_producto;
          public          postgres    false    237            �            1259    25813    Dispositivo_id_producto_seq    SEQUENCE     �   CREATE SEQUENCE public."Dispositivo_id_producto_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 4   DROP SEQUENCE public."Dispositivo_id_producto_seq";
       public          postgres    false    233            �           0    0    Dispositivo_id_producto_seq    SEQUENCE OWNED BY     _   ALTER SEQUENCE public."Dispositivo_id_producto_seq" OWNED BY public."Dispositivo".id_producto;
          public          postgres    false    238            �            1259    25814    Paises_Promo    TABLE     ]   CREATE TABLE public."Paises_Promo" (
    id_promo bigint NOT NULL,
    pais text NOT NULL
);
 "   DROP TABLE public."Paises_Promo";
       public         heap    postgres    false            �            1259    25819    Paises_Promo_id_promo_seq    SEQUENCE     �   CREATE SEQUENCE public."Paises_Promo_id_promo_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 2   DROP SEQUENCE public."Paises_Promo_id_promo_seq";
       public          postgres    false    239            �           0    0    Paises_Promo_id_promo_seq    SEQUENCE OWNED BY     [   ALTER SEQUENCE public."Paises_Promo_id_promo_seq" OWNED BY public."Paises_Promo".id_promo;
          public          postgres    false    240            �            1259    25820    Producto_id_producto_seq    SEQUENCE     �   CREATE SEQUENCE public."Producto_id_producto_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public."Producto_id_producto_seq";
       public          postgres    false    235            �           0    0    Producto_id_producto_seq    SEQUENCE OWNED BY     Y   ALTER SEQUENCE public."Producto_id_producto_seq" OWNED BY public."Producto".id_producto;
          public          postgres    false    241            �            1259    25821 	   Promocion    TABLE     w  CREATE TABLE public."Promocion" (
    id_promo bigint NOT NULL,
    fecha_inicio date NOT NULL,
    fecha_fin date NOT NULL,
    duracion_promocion smallint,
    descuento real NOT NULL,
    CONSTRAINT check_descuento CHECK (((descuento >= (0)::double precision) AND (descuento <= (100)::double precision))),
    CONSTRAINT check_fecha CHECK ((fecha_fin >= fecha_inicio))
);
    DROP TABLE public."Promocion";
       public         heap    postgres    false            �            1259    25826    Promocion_Especial    TABLE     �   CREATE TABLE public."Promocion_Especial" (
    id_promo_especial bigint NOT NULL,
    fecha_inicio date NOT NULL,
    fecha_fin date,
    id_usuario bigint NOT NULL
);
 (   DROP TABLE public."Promocion_Especial";
       public         heap    postgres    false            �            1259    25829 (   Promocion_Especial_id_promo_especial_seq    SEQUENCE     �   CREATE SEQUENCE public."Promocion_Especial_id_promo_especial_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 A   DROP SEQUENCE public."Promocion_Especial_id_promo_especial_seq";
       public          postgres    false    243            �           0    0 (   Promocion_Especial_id_promo_especial_seq    SEQUENCE OWNED BY     y   ALTER SEQUENCE public."Promocion_Especial_id_promo_especial_seq" OWNED BY public."Promocion_Especial".id_promo_especial;
          public          postgres    false    244            �            1259    25830     Promocion_Especial_id_usario_seq    SEQUENCE     �   CREATE SEQUENCE public."Promocion_Especial_id_usario_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 9   DROP SEQUENCE public."Promocion_Especial_id_usario_seq";
       public          postgres    false    243            �           0    0     Promocion_Especial_id_usario_seq    SEQUENCE OWNED BY     j   ALTER SEQUENCE public."Promocion_Especial_id_usario_seq" OWNED BY public."Promocion_Especial".id_usuario;
          public          postgres    false    245            �            1259    25831    Promocion_id_promo_seq    SEQUENCE     �   CREATE SEQUENCE public."Promocion_id_promo_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public."Promocion_id_promo_seq";
       public          postgres    false    242            �           0    0    Promocion_id_promo_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public."Promocion_id_promo_seq" OWNED BY public."Promocion".id_promo;
          public          postgres    false    246            �            1259    25832    Proveedor_id_proveedor_seq    SEQUENCE     �   CREATE SEQUENCE public."Proveedor_id_proveedor_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public."Proveedor_id_proveedor_seq";
       public          postgres    false    228            �           0    0    Proveedor_id_proveedor_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public."Proveedor_id_proveedor_seq" OWNED BY public."Proveedor".id_proveedor;
          public          postgres    false    247            �            1259    25833    Usuario_id_usuario_seq    SEQUENCE     �   CREATE SEQUENCE public."Usuario_id_usuario_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public."Usuario_id_usuario_seq";
       public          postgres    false    230            �           0    0    Usuario_id_usuario_seq    SEQUENCE OWNED BY     U   ALTER SEQUENCE public."Usuario_id_usuario_seq" OWNED BY public."Usuario".id_usuario;
          public          postgres    false    248            �           2604    25834    Aplicacion id_producto    DEFAULT     �   ALTER TABLE ONLY public."Aplicacion" ALTER COLUMN id_producto SET DEFAULT nextval('public."Aplicacion_id_producto_seq"'::regclass);
 G   ALTER TABLE public."Aplicacion" ALTER COLUMN id_producto DROP DEFAULT;
       public          postgres    false    216    215            �           2604    25835    Aplicacion id_proveedor    DEFAULT     �   ALTER TABLE ONLY public."Aplicacion" ALTER COLUMN id_proveedor SET DEFAULT nextval('public."Aplicacion_id_proveedor_seq"'::regclass);
 H   ALTER TABLE public."Aplicacion" ALTER COLUMN id_proveedor DROP DEFAULT;
       public          postgres    false    217    215            �           2604    25836    Artista id_artista    DEFAULT     |   ALTER TABLE ONLY public."Artista" ALTER COLUMN id_artista SET DEFAULT nextval('public."Artista_id_artista_seq"'::regclass);
 C   ALTER TABLE public."Artista" ALTER COLUMN id_artista DROP DEFAULT;
       public          postgres    false    219    218            �           2604    25837    Cancion id_producto    DEFAULT     ~   ALTER TABLE ONLY public."Cancion" ALTER COLUMN id_producto SET DEFAULT nextval('public."Cancion_id_producto_seq"'::regclass);
 D   ALTER TABLE public."Cancion" ALTER COLUMN id_producto DROP DEFAULT;
       public          postgres    false    222    220            �           2604    25838    Cancion id_artista    DEFAULT     |   ALTER TABLE ONLY public."Cancion" ALTER COLUMN id_artista SET DEFAULT nextval('public."Cancion_id_artista_seq"'::regclass);
 C   ALTER TABLE public."Cancion" ALTER COLUMN id_artista DROP DEFAULT;
       public          postgres    false    221    220            �           2604    25839    Compra id_usuario    DEFAULT     z   ALTER TABLE ONLY public."Compra" ALTER COLUMN id_usuario SET DEFAULT nextval('public."Compra_id_usuario_seq"'::regclass);
 B   ALTER TABLE public."Compra" ALTER COLUMN id_usuario DROP DEFAULT;
       public          postgres    false    227    224            �           2604    25840    Compra id_producto    DEFAULT     |   ALTER TABLE ONLY public."Compra" ALTER COLUMN id_producto SET DEFAULT nextval('public."Compra_id_producto_seq"'::regclass);
 C   ALTER TABLE public."Compra" ALTER COLUMN id_producto DROP DEFAULT;
       public          postgres    false    225    224            �           2604    25841    Compra id_promo    DEFAULT     v   ALTER TABLE ONLY public."Compra" ALTER COLUMN id_promo SET DEFAULT nextval('public."Compra_id_promo_seq"'::regclass);
 @   ALTER TABLE public."Compra" ALTER COLUMN id_promo DROP DEFAULT;
       public          postgres    false    226    224            �           2604    25842    Dispositivo id_producto    DEFAULT     �   ALTER TABLE ONLY public."Dispositivo" ALTER COLUMN id_producto SET DEFAULT nextval('public."Dispositivo_id_producto_seq"'::regclass);
 H   ALTER TABLE public."Dispositivo" ALTER COLUMN id_producto DROP DEFAULT;
       public          postgres    false    238    233            �           2604    25843 "   Dispositivo_Aplicacion id_producto    DEFAULT     �   ALTER TABLE ONLY public."Dispositivo_Aplicacion" ALTER COLUMN id_producto SET DEFAULT nextval('public."Dispositivo_Aplicacion_id_producto_seq"'::regclass);
 S   ALTER TABLE public."Dispositivo_Aplicacion" ALTER COLUMN id_producto DROP DEFAULT;
       public          postgres    false    237    234            �           2604    25844    Paises_Promo id_promo    DEFAULT     �   ALTER TABLE ONLY public."Paises_Promo" ALTER COLUMN id_promo SET DEFAULT nextval('public."Paises_Promo_id_promo_seq"'::regclass);
 F   ALTER TABLE public."Paises_Promo" ALTER COLUMN id_promo DROP DEFAULT;
       public          postgres    false    240    239            �           2604    25845    Producto id_producto    DEFAULT     �   ALTER TABLE ONLY public."Producto" ALTER COLUMN id_producto SET DEFAULT nextval('public."Producto_id_producto_seq"'::regclass);
 E   ALTER TABLE public."Producto" ALTER COLUMN id_producto DROP DEFAULT;
       public          postgres    false    241    235            �           2604    25846    Promocion id_promo    DEFAULT     |   ALTER TABLE ONLY public."Promocion" ALTER COLUMN id_promo SET DEFAULT nextval('public."Promocion_id_promo_seq"'::regclass);
 C   ALTER TABLE public."Promocion" ALTER COLUMN id_promo DROP DEFAULT;
       public          postgres    false    246    242            �           2604    25847 $   Promocion_Especial id_promo_especial    DEFAULT     �   ALTER TABLE ONLY public."Promocion_Especial" ALTER COLUMN id_promo_especial SET DEFAULT nextval('public."Promocion_Especial_id_promo_especial_seq"'::regclass);
 U   ALTER TABLE public."Promocion_Especial" ALTER COLUMN id_promo_especial DROP DEFAULT;
       public          postgres    false    244    243            �           2604    25848    Promocion_Especial id_usuario    DEFAULT     �   ALTER TABLE ONLY public."Promocion_Especial" ALTER COLUMN id_usuario SET DEFAULT nextval('public."Promocion_Especial_id_usario_seq"'::regclass);
 N   ALTER TABLE public."Promocion_Especial" ALTER COLUMN id_usuario DROP DEFAULT;
       public          postgres    false    245    243            �           2604    25849    Proveedor id_proveedor    DEFAULT     �   ALTER TABLE ONLY public."Proveedor" ALTER COLUMN id_proveedor SET DEFAULT nextval('public."Proveedor_id_proveedor_seq"'::regclass);
 G   ALTER TABLE public."Proveedor" ALTER COLUMN id_proveedor DROP DEFAULT;
       public          postgres    false    247    228            �           2604    25850    Usuario id_usuario    DEFAULT     |   ALTER TABLE ONLY public."Usuario" ALTER COLUMN id_usuario SET DEFAULT nextval('public."Usuario_id_usuario_seq"'::regclass);
 C   ALTER TABLE public."Usuario" ALTER COLUMN id_usuario DROP DEFAULT;
       public          postgres    false    248    230            �          0    25719 
   Aplicacion 
   TABLE DATA           �   COPY public."Aplicacion" (id_producto, tamano_mb, version, nombre_aplicacion, descripcion, version_ios, tematica, id_proveedor) FROM stdin;
    public          postgres    false    215   9�       �          0    25729    Artista 
   TABLE DATA           d   COPY public."Artista" (id_artista, nom_artistico, nombre_casa, fecha_inicio, fecha_fin) FROM stdin;
    public          postgres    false    218   ��       �          0    25737    Cancion 
   TABLE DATA           �   COPY public."Cancion" (id_producto, nom_cancion, fecha_lanz, duracion_cancion, genero, unidades_vendidas, nom_disco, id_artista) FROM stdin;
    public          postgres    false    220   �       �          0    25745    Casa_Disquera 
   TABLE DATA           F   COPY public."Casa_Disquera" (nombre_casa, direccion_casa) FROM stdin;
    public          postgres    false    223   `�       �          0    25750    Compra 
   TABLE DATA           u   COPY public."Compra" (id_usuario, id_producto, fecha_compra, rating, monto, id_promo, id_promo_especial) FROM stdin;
    public          postgres    false    224   �       �          0    25783    Dispositivo 
   TABLE DATA           `   COPY public."Dispositivo" (id_producto, modelo, generacion, version_ios, capacidad) FROM stdin;
    public          postgres    false    233   u�       �          0    25791    Dispositivo_Aplicacion 
   TABLE DATA           W   COPY public."Dispositivo_Aplicacion" (id_producto, dispositivo_compatible) FROM stdin;
    public          postgres    false    234   1�       �          0    25814    Paises_Promo 
   TABLE DATA           8   COPY public."Paises_Promo" (id_promo, pais) FROM stdin;
    public          postgres    false    239   ��       �          0    25796    Producto 
   TABLE DATA           D   COPY public."Producto" (id_producto, costo, puntuacion) FROM stdin;
    public          postgres    false    235   ��       �          0    25821 	   Promocion 
   TABLE DATA           g   COPY public."Promocion" (id_promo, fecha_inicio, fecha_fin, duracion_promocion, descuento) FROM stdin;
    public          postgres    false    242   I�       �          0    25826    Promocion_Especial 
   TABLE DATA           f   COPY public."Promocion_Especial" (id_promo_especial, fecha_inicio, fecha_fin, id_usuario) FROM stdin;
    public          postgres    false    243   ��       �          0    25756 	   Proveedor 
   TABLE DATA           �   COPY public."Proveedor" (id_proveedor, nombre_proveedor, correo_proveedor, direccion_proveedor, fecha_afiliacion, tipo_proveedor) FROM stdin;
    public          postgres    false    228   �       �          0    25768    Usuario 
   TABLE DATA           �   COPY public."Usuario" (id_usuario, nombre_usuario, apellido_usuario, correo_usuario, ciudad_usuario, pais_usuario, fecha_venc, num_tdc, cod_vvt) FROM stdin;
    public          postgres    false    230   $�       �           0    0    Aplicacion_id_producto_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public."Aplicacion_id_producto_seq"', 1, false);
          public          postgres    false    216            �           0    0    Aplicacion_id_proveedor_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public."Aplicacion_id_proveedor_seq"', 1, false);
          public          postgres    false    217            �           0    0    Artista_id_artista_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public."Artista_id_artista_seq"', 12, true);
          public          postgres    false    219            �           0    0    Cancion_id_artista_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public."Cancion_id_artista_seq"', 1, false);
          public          postgres    false    221            �           0    0    Cancion_id_producto_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public."Cancion_id_producto_seq"', 1, false);
          public          postgres    false    222            �           0    0    Compra_id_producto_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public."Compra_id_producto_seq"', 1, false);
          public          postgres    false    225            �           0    0    Compra_id_promo_seq    SEQUENCE SET     D   SELECT pg_catalog.setval('public."Compra_id_promo_seq"', 1, false);
          public          postgres    false    226            �           0    0    Compra_id_usuario_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public."Compra_id_usuario_seq"', 1, false);
          public          postgres    false    227            �           0    0 &   Dispositivo_Aplicacion_id_producto_seq    SEQUENCE SET     W   SELECT pg_catalog.setval('public."Dispositivo_Aplicacion_id_producto_seq"', 1, false);
          public          postgres    false    237            �           0    0    Dispositivo_id_producto_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public."Dispositivo_id_producto_seq"', 1, false);
          public          postgres    false    238            �           0    0    Paises_Promo_id_promo_seq    SEQUENCE SET     J   SELECT pg_catalog.setval('public."Paises_Promo_id_promo_seq"', 1, false);
          public          postgres    false    240            �           0    0    Producto_id_producto_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public."Producto_id_producto_seq"', 36, true);
          public          postgres    false    241            �           0    0 (   Promocion_Especial_id_promo_especial_seq    SEQUENCE SET     X   SELECT pg_catalog.setval('public."Promocion_Especial_id_promo_especial_seq"', 5, true);
          public          postgres    false    244            �           0    0     Promocion_Especial_id_usario_seq    SEQUENCE SET     Q   SELECT pg_catalog.setval('public."Promocion_Especial_id_usario_seq"', 1, false);
          public          postgres    false    245            �           0    0    Promocion_id_promo_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public."Promocion_id_promo_seq"', 10, true);
          public          postgres    false    246            �           0    0    Proveedor_id_proveedor_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public."Proveedor_id_proveedor_seq"', 11, true);
          public          postgres    false    247            �           0    0    Usuario_id_usuario_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public."Usuario_id_usuario_seq"', 16, true);
          public          postgres    false    248            �           2606    25852    Aplicacion Aplicacion_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public."Aplicacion"
    ADD CONSTRAINT "Aplicacion_pkey" PRIMARY KEY (id_producto);
 H   ALTER TABLE ONLY public."Aplicacion" DROP CONSTRAINT "Aplicacion_pkey";
       public            postgres    false    215            �           2606    25854    Artista Artista_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public."Artista"
    ADD CONSTRAINT "Artista_pkey" PRIMARY KEY (id_artista);
 B   ALTER TABLE ONLY public."Artista" DROP CONSTRAINT "Artista_pkey";
       public            postgres    false    218            �           2606    25856    Cancion Cancion_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public."Cancion"
    ADD CONSTRAINT "Cancion_pkey" PRIMARY KEY (id_producto);
 B   ALTER TABLE ONLY public."Cancion" DROP CONSTRAINT "Cancion_pkey";
       public            postgres    false    220            �           2606    25858     Casa_Disquera Casa_Disquera_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY public."Casa_Disquera"
    ADD CONSTRAINT "Casa_Disquera_pkey" PRIMARY KEY (nombre_casa);
 N   ALTER TABLE ONLY public."Casa_Disquera" DROP CONSTRAINT "Casa_Disquera_pkey";
       public            postgres    false    223            �           2606    25860    Compra Compra_pkey 
   CONSTRAINT     w   ALTER TABLE ONLY public."Compra"
    ADD CONSTRAINT "Compra_pkey" PRIMARY KEY (id_usuario, id_producto, fecha_compra);
 @   ALTER TABLE ONLY public."Compra" DROP CONSTRAINT "Compra_pkey";
       public            postgres    false    224    224    224            �           2606    25862 2   Dispositivo_Aplicacion Dispositivo_Aplicacion_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public."Dispositivo_Aplicacion"
    ADD CONSTRAINT "Dispositivo_Aplicacion_pkey" PRIMARY KEY (id_producto, dispositivo_compatible);
 `   ALTER TABLE ONLY public."Dispositivo_Aplicacion" DROP CONSTRAINT "Dispositivo_Aplicacion_pkey";
       public            postgres    false    234    234            �           2606    25864    Dispositivo Dispositivo_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY public."Dispositivo"
    ADD CONSTRAINT "Dispositivo_pkey" PRIMARY KEY (id_producto);
 J   ALTER TABLE ONLY public."Dispositivo" DROP CONSTRAINT "Dispositivo_pkey";
       public            postgres    false    233            �           2606    25866    Paises_Promo Paises_Promo_pkey 
   CONSTRAINT     l   ALTER TABLE ONLY public."Paises_Promo"
    ADD CONSTRAINT "Paises_Promo_pkey" PRIMARY KEY (id_promo, pais);
 L   ALTER TABLE ONLY public."Paises_Promo" DROP CONSTRAINT "Paises_Promo_pkey";
       public            postgres    false    239    239            �           2606    25868    Producto Producto_pkey 
   CONSTRAINT     a   ALTER TABLE ONLY public."Producto"
    ADD CONSTRAINT "Producto_pkey" PRIMARY KEY (id_producto);
 D   ALTER TABLE ONLY public."Producto" DROP CONSTRAINT "Producto_pkey";
       public            postgres    false    235            �           2606    25870 *   Promocion_Especial Promocion_Especial_pkey 
   CONSTRAINT     {   ALTER TABLE ONLY public."Promocion_Especial"
    ADD CONSTRAINT "Promocion_Especial_pkey" PRIMARY KEY (id_promo_especial);
 X   ALTER TABLE ONLY public."Promocion_Especial" DROP CONSTRAINT "Promocion_Especial_pkey";
       public            postgres    false    243            �           2606    25872    Promocion Promocion_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public."Promocion"
    ADD CONSTRAINT "Promocion_pkey" PRIMARY KEY (id_promo);
 F   ALTER TABLE ONLY public."Promocion" DROP CONSTRAINT "Promocion_pkey";
       public            postgres    false    242            �           2606    25874    Proveedor Proveedor_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public."Proveedor"
    ADD CONSTRAINT "Proveedor_pkey" PRIMARY KEY (id_proveedor);
 F   ALTER TABLE ONLY public."Proveedor" DROP CONSTRAINT "Proveedor_pkey";
       public            postgres    false    228            �           2606    25876    Usuario Usuario_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public."Usuario"
    ADD CONSTRAINT "Usuario_pkey" PRIMARY KEY (id_usuario);
 B   ALTER TABLE ONLY public."Usuario" DROP CONSTRAINT "Usuario_pkey";
       public            postgres    false    230            �           2606    25877    Usuario check_cod_vvt    CHECK CONSTRAINT     z   ALTER TABLE public."Usuario"
    ADD CONSTRAINT check_cod_vvt CHECK (((cod_vvt >= 100) AND (cod_vvt <= 9999))) NOT VALID;
 <   ALTER TABLE public."Usuario" DROP CONSTRAINT check_cod_vvt;
       public          postgres    false    230    230            �           2606    25878    Usuario check_correo_format    CHECK CONSTRAINT     �   ALTER TABLE public."Usuario"
    ADD CONSTRAINT check_correo_format CHECK ((correo_usuario ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$'::text)) NOT VALID;
 B   ALTER TABLE public."Usuario" DROP CONSTRAINT check_correo_format;
       public          postgres    false    230    230            �           2606    25880    Usuario check_correo_unico 
   CONSTRAINT     t   ALTER TABLE ONLY public."Usuario"
    ADD CONSTRAINT check_correo_unico UNIQUE NULLS NOT DISTINCT (correo_usuario);
 F   ALTER TABLE ONLY public."Usuario" DROP CONSTRAINT check_correo_unico;
       public            postgres    false    230            �           2606    25882    Proveedor check_correo_unique 
   CONSTRAINT     y   ALTER TABLE ONLY public."Proveedor"
    ADD CONSTRAINT check_correo_unique UNIQUE NULLS NOT DISTINCT (correo_proveedor);
 I   ALTER TABLE ONLY public."Proveedor" DROP CONSTRAINT check_correo_unique;
       public            postgres    false    228            �           2606    25883    Cancion check_duracion    CHECK CONSTRAINT     i   ALTER TABLE public."Cancion"
    ADD CONSTRAINT check_duracion CHECK ((duracion_cancion > 0)) NOT VALID;
 =   ALTER TABLE public."Cancion" DROP CONSTRAINT check_duracion;
       public          postgres    false    220    220            �           2606    25884    Usuario check_fecha    CHECK CONSTRAINT     l   ALTER TABLE public."Usuario"
    ADD CONSTRAINT check_fecha CHECK ((fecha_venc >= CURRENT_DATE)) NOT VALID;
 :   ALTER TABLE public."Usuario" DROP CONSTRAINT check_fecha;
       public          postgres    false    230    230            �           2606    25885    Compra check_fecha    CHECK CONSTRAINT     m   ALTER TABLE public."Compra"
    ADD CONSTRAINT check_fecha CHECK ((fecha_compra <= CURRENT_DATE)) NOT VALID;
 9   ALTER TABLE public."Compra" DROP CONSTRAINT check_fecha;
       public          postgres    false    224    224            �           2606    25886    Usuario check_num_tdc    CHECK CONSTRAINT     �   ALTER TABLE public."Usuario"
    ADD CONSTRAINT check_num_tdc CHECK (((num_tdc >= '100000000000000'::bigint) AND (num_tdc <= '9999999999999999'::bigint))) NOT VALID;
 <   ALTER TABLE public."Usuario" DROP CONSTRAINT check_num_tdc;
       public          postgres    false    230    230            �           2606    25887    Compra check_rating    CHECK CONSTRAINT     q   ALTER TABLE public."Compra"
    ADD CONSTRAINT check_rating CHECK (((rating >= 0) AND (rating <= 5))) NOT VALID;
 :   ALTER TABLE public."Compra" DROP CONSTRAINT check_rating;
       public          postgres    false    224    224            �           2606    25888    Cancion check_unidades    CHECK CONSTRAINT     k   ALTER TABLE public."Cancion"
    ADD CONSTRAINT check_unidades CHECK ((unidades_vendidas >= 0)) NOT VALID;
 =   ALTER TABLE public."Cancion" DROP CONSTRAINT check_unidades;
       public          postgres    false    220    220                       2620    25889    Compra trigger_cancion_vendida    TRIGGER     �   CREATE TRIGGER trigger_cancion_vendida AFTER INSERT OR UPDATE OF id_producto ON public."Compra" FOR EACH ROW EXECUTE FUNCTION public.contar_unidades_vendidas();
 9   DROP TRIGGER trigger_cancion_vendida ON public."Compra";
       public          postgres    false    253    224    224                       2620    25890 !   Compra trigger_compatibilidad_app    TRIGGER     �   CREATE TRIGGER trigger_compatibilidad_app BEFORE INSERT OR UPDATE OF id_producto ON public."Compra" FOR EACH ROW EXECUTE FUNCTION public.verificar_compatibilidad();
 <   DROP TRIGGER trigger_compatibilidad_app ON public."Compra";
       public          postgres    false    267    224    224                       2620    25891     Promocion trigger_duracion_promo    TRIGGER     �   CREATE TRIGGER trigger_duracion_promo BEFORE INSERT OR UPDATE OF fecha_inicio, fecha_fin ON public."Promocion" FOR EACH ROW EXECUTE FUNCTION public.calcular_duracion();
 ;   DROP TRIGGER trigger_duracion_promo ON public."Promocion";
       public          postgres    false    242    250    242    242                       2620    25892 $   Promocion_Especial trigger_fecha_fin    TRIGGER     �   CREATE TRIGGER trigger_fecha_fin BEFORE INSERT OR UPDATE OF fecha_inicio ON public."Promocion_Especial" FOR EACH ROW EXECUTE FUNCTION public.calcular_fecha_fin_pe();
 ?   DROP TRIGGER trigger_fecha_fin ON public."Promocion_Especial";
       public          postgres    false    243    243    251                       2620    25893    Compra trigger_promo_especial    TRIGGER     �   CREATE TRIGGER trigger_promo_especial AFTER INSERT OR UPDATE OF fecha_compra ON public."Compra" FOR EACH ROW EXECUTE FUNCTION public.crear_promo_especial();
 8   DROP TRIGGER trigger_promo_especial ON public."Compra";
       public          postgres    false    224    254    224                       2620    25894    Compra trigger_promocion    TRIGGER     z   CREATE TRIGGER trigger_promocion BEFORE INSERT ON public."Compra" FOR EACH ROW EXECUTE FUNCTION public.verificar_promo();
 3   DROP TRIGGER trigger_promocion ON public."Compra";
       public          postgres    false    224    266                       2620    25895 "   Compra trigger_puntuacion_promedio    TRIGGER     �   CREATE TRIGGER trigger_puntuacion_promedio AFTER INSERT OR UPDATE OF rating, id_producto ON public."Compra" FOR EACH ROW EXECUTE FUNCTION public.calcular_promedio_puntuacion();
 =   DROP TRIGGER trigger_puntuacion_promedio ON public."Compra";
       public          postgres    false    224    224    252    224                        2606    25896 !   Aplicacion Aplicacion_Producto_FK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Aplicacion"
    ADD CONSTRAINT "Aplicacion_Producto_FK" FOREIGN KEY (id_producto) REFERENCES public."Producto"(id_producto) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 O   ALTER TABLE ONLY public."Aplicacion" DROP CONSTRAINT "Aplicacion_Producto_FK";
       public          postgres    false    4857    235    215                       2606    25901 "   Aplicacion Aplicacion_Proveedor_FK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Aplicacion"
    ADD CONSTRAINT "Aplicacion_Proveedor_FK" FOREIGN KEY (id_proveedor) REFERENCES public."Proveedor"(id_proveedor);
 P   ALTER TABLE ONLY public."Aplicacion" DROP CONSTRAINT "Aplicacion_Proveedor_FK";
       public          postgres    false    228    215    4845                       2606    25906    Artista Artista_DisqueraFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Artista"
    ADD CONSTRAINT "Artista_DisqueraFK" FOREIGN KEY (nombre_casa) REFERENCES public."Casa_Disquera"(nombre_casa) ON UPDATE CASCADE ON DELETE SET DEFAULT;
 H   ALTER TABLE ONLY public."Artista" DROP CONSTRAINT "Artista_DisqueraFK";
       public          postgres    false    4841    218    223                       2606    25911    Cancion Cancion_ArtistaFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Cancion"
    ADD CONSTRAINT "Cancion_ArtistaFK" FOREIGN KEY (id_artista) REFERENCES public."Artista"(id_artista) ON UPDATE CASCADE;
 G   ALTER TABLE ONLY public."Cancion" DROP CONSTRAINT "Cancion_ArtistaFK";
       public          postgres    false    218    4837    220                       2606    25916    Cancion Cancion_ProductoFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Cancion"
    ADD CONSTRAINT "Cancion_ProductoFK" FOREIGN KEY (id_producto) REFERENCES public."Producto"(id_producto) ON UPDATE CASCADE ON DELETE CASCADE;
 H   ALTER TABLE ONLY public."Cancion" DROP CONSTRAINT "Cancion_ProductoFK";
       public          postgres    false    4857    220    235                       2606    25921    Compra Compra_ProductoFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Compra"
    ADD CONSTRAINT "Compra_ProductoFK" FOREIGN KEY (id_producto) REFERENCES public."Producto"(id_producto) ON UPDATE CASCADE;
 F   ALTER TABLE ONLY public."Compra" DROP CONSTRAINT "Compra_ProductoFK";
       public          postgres    false    224    4857    235                       2606    25926    Compra Compra_PromocionEFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Compra"
    ADD CONSTRAINT "Compra_PromocionEFK" FOREIGN KEY (id_promo_especial) REFERENCES public."Promocion_Especial"(id_promo_especial) NOT VALID;
 H   ALTER TABLE ONLY public."Compra" DROP CONSTRAINT "Compra_PromocionEFK";
       public          postgres    false    243    4863    224                       2606    25931    Compra Compra_PromocionFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Compra"
    ADD CONSTRAINT "Compra_PromocionFK" FOREIGN KEY (id_promo) REFERENCES public."Promocion"(id_promo) NOT VALID;
 G   ALTER TABLE ONLY public."Compra" DROP CONSTRAINT "Compra_PromocionFK";
       public          postgres    false    224    4861    242                       2606    25936    Compra Compra_UsuarioFk    FK CONSTRAINT     �   ALTER TABLE ONLY public."Compra"
    ADD CONSTRAINT "Compra_UsuarioFk" FOREIGN KEY (id_usuario) REFERENCES public."Usuario"(id_usuario) ON UPDATE CASCADE;
 E   ALTER TABLE ONLY public."Compra" DROP CONSTRAINT "Compra_UsuarioFk";
       public          postgres    false    4849    230    224            
           2606    25941 /   Dispositivo_Aplicacion Dispositivo_AplicacionFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Dispositivo_Aplicacion"
    ADD CONSTRAINT "Dispositivo_AplicacionFK" FOREIGN KEY (id_producto) REFERENCES public."Aplicacion"(id_producto) ON UPDATE CASCADE ON DELETE CASCADE;
 ]   ALTER TABLE ONLY public."Dispositivo_Aplicacion" DROP CONSTRAINT "Dispositivo_AplicacionFK";
       public          postgres    false    215    4835    234            	           2606    25946 "   Dispositivo Dispositivo_ProductoFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Dispositivo"
    ADD CONSTRAINT "Dispositivo_ProductoFK" FOREIGN KEY (id_producto) REFERENCES public."Producto"(id_producto) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 P   ALTER TABLE ONLY public."Dispositivo" DROP CONSTRAINT "Dispositivo_ProductoFK";
       public          postgres    false    233    235    4857                       2606    25951    Paises_Promo Pais_PromoFK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Paises_Promo"
    ADD CONSTRAINT "Pais_PromoFK" FOREIGN KEY (id_promo) REFERENCES public."Promocion"(id_promo) ON UPDATE CASCADE ON DELETE CASCADE;
 G   ALTER TABLE ONLY public."Paises_Promo" DROP CONSTRAINT "Pais_PromoFK";
       public          postgres    false    4861    239    242                       2606    25956 #   Promocion_Especial Promo_Usuario_FK    FK CONSTRAINT     �   ALTER TABLE ONLY public."Promocion_Especial"
    ADD CONSTRAINT "Promo_Usuario_FK" FOREIGN KEY (id_usuario) REFERENCES public."Usuario"(id_usuario) ON UPDATE CASCADE ON DELETE CASCADE;
 Q   ALTER TABLE ONLY public."Promocion_Especial" DROP CONSTRAINT "Promo_Usuario_FK";
       public          postgres    false    230    4849    243            �   �  x��TAn�0<�^����d;��A[�I�����Ä"�
����^��<!?�K���*�"� q	rwvvFJ�:-@�j��I^(87�u��4��#�o[�z�7�߷�'/l|�GL�\������P�d�[���ԟL����$� �&��Pf���B�%ل�q�M��8`Rc�&m��\�f�1ց5'�����^GPd��re��55��^�6�99�J���;�R�6��aK�<J�*'�KhM��+oIڭ�@�����k�QP��b>�=B9X�r�g���&�̫��ƥ���R[�KT<�Z/�bK�Ȃ�$�n��;���/JА`���õ�UfkY޳iY�6L35��T0�'���w���w�Vf�����L�Cq��
�,�ʈ|
f���rE���ל��R�9���|0�
��j��L���H!xk��ۀ~s�\Q-M.FE�3u
�R\Qt��??E��9�+�+�	���X��i�%'n`�O�?��$�NF֡�1�����n+�<�s�)��f���W芬�{~�#="ڵ�R��cGS�G�]�l
Ť����U��-��e�o:ݵ��{m
e�}Da�$Q#��O�F%(��T�igy#�W�PQ��O>л����O^����J�n^����{��<��G�e�_+~�f      �   (  x�u�KN�0E�/���l�i�a*�h�N��,R;��%�6��"�A�yp���9�1}����iýV���jl�@0&([RV���S�)�3�2�ƒ�S�<��u��#K0ڋ.�l՛|WVBet$������J�Q{�e���rX5��TM�����zl� ɓ�$�H���{kB׳9e�а��j1�M��M�y�x��FR�آ��X�=���UR�t��N��d��38�&k�5Z���}��~�5���a�#'r6.���8/�|�
��Ր}@�������^�<dY�����      �   1  x�]R�n�@>�>���Ȼ�NU��
	
��V�,0���]�^q�c���$�S��l��|�
n,�M�ˊ@��$&jȏ
�n)��]N�-޺o��;K5d"��7��KW�T*�$��@�3x��?�"*DoD�KS��������-%!�sxp�W_�vL ��<���Y�,H)
x�N���ʒ�,@���HB�<Ű��s�4v� ��F*9�a�+�֌���5�2��ٺ��T�x"�LR���k�@.��Sk��ѱ�&�gdV�z�//�C4u0G���; ��z�p�P����D�4�ta����9�Td9\;��YvǨ�16u��u�_�����g��׏���
�-�����{����)��v�C��pd~�򐼀F˒{��xH敢��N�Up|�6�y�9�NI{.���Gީ5��$aat��&N���G�s\6CI8�� �E�x��zK�!��_'I1Yn<K�+�����y�`���O���)��Ag#����U�l��=��n|S��w^�i��,О��D�+���1�9      �     x����j�@�����e�.S+�R{a�E�f4S�t�	�ŷo !��{77ߙ��#9��7;�wRW��Z�L�8,�#qM	�a!lv��,���a�"��s1�@.��q�t,��s��kq�͵��R�f��cr_D�4�['X���9m�<�ƭ���W�k�V&���ƙ�g�EpD!�G��,���ғ��Wx�C��hҴ�����v�MR�3�_T�Q�*�>l�\֨����-<�.��������a�YvŰ��8�? .n�      �   �   x���Q�� E��^4\�
�x+���c�֎mf�ט��8@%q�'�$L����gS�HJ���j.J{��D�A��zf��A˃r�:��S陹D栳l���$F�Av�Ӊ[BT!����Hk��7 ����6nTh�=����EPDKsNas�~֎v���;.1Y�Ko,ƹ�a�c�������/�g�v�Zxyx[E��?(:V�{�T��}ū��m�╷m{��q      �   �   x�U��
�0���S�	��]�G�������̂gEw�㯝��/������$C�L$�d��F��
�a�,��������Ȁ�|�8y�P�F� uk����#�O�2���[�f������r���ɿl T���#H�d�v��:G��[�]A�L��s�l��O��X�C ��L>      �   �   x�34�����KU04�2D�(�CS3������&���88�L�	�5Eb����F�!�l�n�9f����K< �cAAN�BxbIr�B�+�HjQfj�����6d��=... �kj�      �   �   x�]��jA�����'(Z{��,���(��kX���H��7#ū|g����!�!Շ��V�@��aGJ}��� �a}��>k�X�(�>Y�7s �³��Rh�(\`-�Ί�3x�SԢ�1U�{6�߷��+�H���@��	[�=�~/�6��p	u���?]J,�-�/���y���S�z1J�Y��z���]\c]���~@�?��g      �   �   x�E��!��'�.�\��:�8�QO�@?((�x�G���#V��ݪÓ�)���*d�A,�p�<"�Ġ̨_II�zG�_��e �Hr	9	���(��)goC�'X [=4d����4��5�弽�=3��ú����7�?�      �   �   x�]�A!��&4����c%�fomWl
ME�e�����E48��i����7'���(t�|)��0Y:#jzE�:��*���y�y9E-��'��U3�Q�8�yڶX�{ko�_���g��������G�}."z �3�      �      x�3�4202�50"(��44������ [�C      �     x�eR]n�@~^N1����7BB$h�y���ޘ	�]kwM���&�XǦP�J^kv������X�.�k���q���e�������h���z��d�,���~(FQ�Q̟XV���ؘw�%l}S�q"7�c��U���	l���hT�~m����*�8��8�V#sB���hܟ���&���3j������[��K�`mr���6�xdLk�RX;�-���𢽴̜NR�SI������� v�*������U��?w&�;S�Bᚺ6��Y�7u��tg⍦�j2PH�׵B�^�r�Gϙ8	�i'7�ē�Z���H�����n7"���C�$��gVJ���%�ڄJ�d;6��摦��#m]�����x4�����Z\�웄�P �$�ƪ�ͦL��-�ؙ��ws�
��t0����O;;<�;G�3KRIX�m�"Q��G�rg����I��>1b��Ao�ű�6���T���t�2�r����tk�u>m��`0���!�      �   �  x����n�0�������p״��
tK7`�nGs��r*�ҧ��":�@�����SV&X�q�RX��<6�0mϚ���!i�n��f��+i=cN()AJS	X�m��c����T�36X�GH�i
�"jk�j�@Xg8��1I�J�Ү��>cjb��ÔZ�}�s���]l�ઌ�ʻ�)��\���ǹ3�*�i�%h�+7��a�`���1k˜���z�+��ٚ+��).�s�(��H��J�u(%�mL�=��3�<�ʯ���0�L�+;��ɚx�f�'ʹ`��o�aMdv�	2%��np1�D���C�UnCcZ�j�k�@K����
�� �le�[h��>���m^�S�[jtyn>KR{Oz�B���|��z�a"�,D����:U�:�MhN�G�Y�%:��@�Q@A��.X��Ⲅ/xئp��Tƌ�R�d5[m���)E�c҃����;�{<��#��c��-���-X��wT��Fr�!
��gS,��C&�!�}���1v��a���R��r^t��f����f�aF	j���=|�n��؎�K����"Lm��XH7�
��@SQٷ��'[7�<��ؗc�����q^�R��� ��n���{KrY��E�`.�{B)���ۦ���)X�-VC��A#�묪�@Pm     