-- compléter l'entête 
-- ==================

-- NOM    :
-- Prénom :

-- NOM    :
-- Prénom :

-- Groupe :
-- binome :

-- ================================================

-- suppression des types créés
-- ==========================

-- drop type Etudiant;
-- drop type Adresse;
-- drop type Cercle;
-- drop type Polygone;
-- drop type Point;


-- définition des types 
-- ====================

-- un étudiant décrit par les attributs nom, prénom, diplôme,
create type etudiant as object(
    nom varchar2(30),
    prenom varchar2(30),
    diplome varchar2(30)
);
/
show errors

-- un module d'enseignement décrit par les attributs nom, diplôme,
create type module as object(
    nom varchar2(30),
    diplome varchar2(30)
);

-- un point du plan euclidien,
create type point as object(
    x number,
    y number
);

-- un cercle,
create type cercle as object(
    centre point,
    rayon number
);