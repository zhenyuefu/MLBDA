--NOM : 
--Prenom : 


-- les Pays
;
SELECT *
FROM country
ORDER BY name
;


-- les ORGANIZATIONs
;
SELECT name
FROM organization
ORDER BY name
;

-- 1 Le nom des pays membres des nations unies trié par nom de pays
;
SELECT c.name
FROM country c,
     organization o,
     ismember m
WHERE c.code = m.country
  AND m.organization = o.abbreviation
  AND o.name = 'United Nations'
ORDER BY c.name
;

-- 2. Idem avec la population, trié décroissant par population
;
SELECT c.population
FROM country c,
     organization o,
     ismember m
WHERE c.code = m.country
  AND m.organization = o.abbreviation
  AND o.name = 'United Nations'
ORDER BY c.population DESC
;

-- 3. Le nom des pays NON membre des nations unies
;
SELECT c.name
FROM country c
WHERE c.name NOT IN (SELECT m.country
                     FROM organization o,
                          ismember m
                     WHERE m.organization = o.abbreviation
                       AND o.name = 'United Nations')
;

-- 4. Les pays frontaliers de la france (solution avec union)
;
SELECT b.country2
FROM country f,
     borders b
WHERE f.code = b.country1
  AND f.name = 'France'
UNION
SELECT b.country1
FROM country f,
     borders b
WHERE f.code = b.country2
  AND f.name = 'France'
;

-- 5. Les pays frontaliers de la france (solution avec OR)
;
SELECT c.name
FROM country f,
     borders b,
     country c
WHERE f.name = 'France'
  AND ((b.country1 = f.code AND b.country2 = c.code) OR (b.country2 = f.code AND b.country1 = c.code))
;

-- 6. La longueur de la frontière française
;
SELECT SUM(b.length)
FROM country f,
     borders b,
     country c
WHERE f.name = 'France'
  AND (b.country1 = f.code OR b.country2 = f.code)
;

-- 7. Pour chaque pays, le nombre de voisins
;
SELECT c.name, COUNT(*)
FROM country c,
     borders b
WHERE b.country1 = c.code
   OR b.country2 = c.code
GROUP BY c.code
;

-- 8. Pour chaque pays, la population totale de ses voisins
;
SELECT c.name, SUM(c2.population)
FROM country c,
     borders b,
     country c2
WHERE (b.country1 = c.code AND b.country2 = c2.code)
   OR (b.country1 = c.code AND b.country2 = c.code)
GROUP BY c.code
;

-- 9. Pour chaque pays d’Europe, la population totale de ses voisins
;
SELECT c.name, SUM(c2.population)
FROM country c,
     borders b,
     country c2,
     encompasses e
WHERE e.country = c.code AND e.continent = 'Europe' AND (b.country1 = c.code AND b.country2 = c2.code)
   OR (b.country1 = c.code AND b.country2 = c.code)
GROUP BY c.code
;

-- 10. Les ORGANIZATIONs, avec le nombre de membre et pop totale.
;
SELECT m.organization, COUNT(*), SUM(c.population)
FROM ismember m,
     country c
WHERE m.country = c.code
GROUP BY m.organization
;

-- 11. Les ORGANIZATIONs regroupant plus de 100 pays, avec le nombre de membre et pop totale
;
SELECT m.organization, COUNT(*), SUM(c.population)
FROM ismember m,
     country c
WHERE m.country = c.code
GROUP BY m.organization
HAVING COUNT(*) > 100
;


-- question 12
;
SELECT c.name, mt.name
FROM country c,
     encompasses e,
     mountain mt
WHERE c.code = e.country
  AND e.continent = 'America'
  AND mt.height = (SELECT MAX(mt1.height)
                   FROM mountain mt1,
                        geo_mountain g_m
                   WHERE g_m.country = c.code
                     AND g_m.mountain = mt1.name)
ORDER BY c.name
;


-- question 13 Les affluents directs du Nil : tous les fleuves qui se jettent dans le Nil.
;
SELECT r.name
FROM river r
WHERE r.river = 'Nile'
;

-- question 14
-- Tous les affluents du Nil : ceux qui s’écoulent directement ou indirectement dans le Nil.
;
SELECT r.name
FROM river r
WHERE r.river = 'Nile'
   OR r.name IN (SELECT r2.name
                 FROM river r1,
                      river r2
                 WHERE r1.river = 'Nile'
                   AND ((r2.river = r1.name)
                     OR (r2.name IN (SELECT r3.name
                                     FROM river r3,
                                          river r4
                                     WHERE r4.river = r1.name
                                       AND r3.river = r4.name)))
    )
;


-- question 15
-- La longueur totale des cours d’eau alimentant le Nil, Nil inclus.
;
SELECT SUM(r.length)
FROM river r
WHERE r.river = 'Nile'
   OR r.name IN (SELECT r2.name
                 FROM river r1,
                      river r2
                 WHERE r1.river = 'Nile'
                   AND ((r2.river = r1.name)
                     OR (r2.name IN (SELECT r3.name
                                     FROM river r3,
                                          river r4
                                     WHERE r4.river = r1.name
                                       AND r3.river = r4.name)))
    )
;

-- question 16A
-- La plus grande ORGANIZATION en termes de nombre pays membre
;
SELECT m.organization, COUNT(*)
FROM ismember m,
     country c
WHERE m.country = c.code
GROUP BY m.organization
ORDER BY COUNT(*) DESC
LIMIT 1
;

-- question 16B
-- Les 3 plus grandes organisations en termes de nombre pays membre
;
SELECT m.organization, COUNT(*)
FROM ismember m,
     country c
WHERE m.country = c.code
GROUP BY m.organization
ORDER BY COUNT(*) DESC
LIMIT 3
;

-- question 17
-- La densité de population (exprimée en nombre d’habitants par km2) de la zone formée de l’Algérie et la Lybie ainsi que de tous leurs voisins directs.
;
SELECT *
FROM country c,
     borders b
WHERE (c.code = b.country1
    AND c.name = 'Algeria')
   OR (c.code = b.country2
    AND c.name = 'Algeria')
;