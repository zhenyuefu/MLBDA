-- calculer le volume, la masse et le prix d'une piece de base
CREATE OR REPLACE TYPE BODY t_piece_base AS
    MEMBER FUNCTION volume RETURN Number IS
    BEGIN
        RETURN 0;
    END volume;
    OVERRIDING MEMBER FUNCTION masse RETURN Number IS
        mv Number;
    BEGIN
        SELECT DEREF(self.est_en).masse_volumique INTO mv FROM dual;
        RETURN self.volume() * mv;
    END;
    OVERRIDING MEMBER FUNCTION prix RETURN Number IS
        pv Number;
    BEGIN
        SELECT DEREF(self.est_en).prix_au_kilo INTO pv FROM dual;
        RETURN self.volume() * pv;
    END;
END;


CREATE OR REPLACE TYPE BODY t_cube AS
    OVERRIDING MEMBER FUNCTION volume RETURN Number IS
    BEGIN
        RETURN cote * cote * cote;
    END;
END;

CREATE OR REPLACE TYPE BODY t_cylindre AS
    OVERRIDING MEMBER FUNCTION volume RETURN Number IS
    BEGIN
        RETURN 3.14 * diametre / 2 * diametre / 2 * hauteur;
    END;
END;

CREATE OR REPLACE TYPE BODY t_sphere AS
    OVERRIDING MEMBER FUNCTION volume RETURN Number IS
    BEGIN
        RETURN 4 / 3 * 3.14 * rayon * rayon * rayon;
    END;
END;

CREATE OR REPLACE TYPE BODY t_paral AS
    OVERRIDING MEMBER FUNCTION volume RETURN Number IS
    BEGIN
        RETURN hauteur * largeur * profondeur;
    END;
END;

SELECT pb.prix()
FROM les_pieces_base pb
WHERE pb.nom = 'clou';
