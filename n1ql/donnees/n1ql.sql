-- 1. L'ensemble des couleurs des produits (ensemble signifie pas de doublons).
SELECT DISTINCT color
FROM product;

-- 2. La liste des prix des 10 premiers produits triés par prix décroissant.
SELECT name, unitPrice
FROM product
ORDER BY unitPrice DESC
LIMIT 10;

-- 3. Les identifiants des produits (productId) ayant au moins une note (rating) de 5. Les identifiants de produits sont tous distincts dans le reéultat.
SELECT DISTINCT productid
FROM reviews
WHERE rating = 5;

-- 4. Les identifiants des clients (customerId) ainsi que leurs emails (emailAddress) qui se terminant par '@herman.com'.
SELECT customerId, emailAddress
FROM customer
WHERE emailAddress LIKE '%@herman.com';

-- 5. Les identifiants des clients (customerId) qui ont acheté exactement 5 produits différents. Les produits achetés sont renseignés par purchases.lineItems. Ne retourner que les customerId uniques.
SELECT customerId
FROM purchases
WHERE ARRAY_LENGTH(lineItems) = 5
GROUP BY customerId;


-- 6. Les identifiants des clients (customerId) ayant acheté au moins un produit avec une quantité > 4. Ne retourner que les customerId uniques.
SELECT p.customerId
FROM purchases p UNNEST lineItems l
WHERE l.count > 4
GROUP BY p.customerId;

-- 7. Les identifiants des clients (customerId) dont tout les produits achetés le sont avec une quantité > 4.
SELECT p.customerId
FROM purchases p
WHERE EVERY l IN p.lineItems SATISFIES l.count > 4 END

-- 8.a) Les paires identifiants de produits (productId) et catégorie. Retourner une paire pour chaque combinaison de productId et de chaine de caractères dans le tableau correspondant à categories.
SELECT productId, categories
FROM product;

-- 8.b) Les identifiants des clients (customerId) et les produits achetés. Chaque client sera retourné autant de fois qu'il a acheté de produits.
SELECT p.customerId, l as item
FROM purchases p UNNEST lineItems l;

-- 9.Les identifiants des clients (customerId) et la liste des produits achetés ; cette liste est obtenue en projetant l'attribut product de lineItems.
SELECT p.customerId, ARRAY_AGG(l.product) AS products
FROM purchases p UNNEST lineItems l
GROUP BY p.customerId;

-- 10. L'identifiant des clients (customerId), leur état de résidence (state) et la liste des produits achetés (lineItems). Compléter la requête ci-dessous.
SELECT p.customerId, c.state, ARRAY_AGG(l.product) AS products
FROM purchases p UNNEST lineItems l
INNER JOIN customer c
ON KEYS p.customerId
GROUP BY p.customerId, c.state;
