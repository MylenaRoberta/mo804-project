// Projeta a rede bipartida com base nos RNAs mensageiros
MATCH (mirnaA:MicroRNA)-[:INTERACTS_WITH]->(mrna:MessengerRNA)
MATCH (mirnaB:MicroRNA)-[:INTERACTS_WITH]->(mrna:MessengerRNA)
WHERE mirnaA.id < mirnaB.id
WITH mirnaA, mirnaB, COUNT(mrna) AS commonMrnas
MERGE (mirnaA)-[r:IS_RELATED_TO]-(mirnaB)
SET r.commonMrnas = commonMrnas;

// Mostra a rede projetada
MATCH (mirnaA:MicroRNA)-[r:IS_RELATED_TO]->(mirnaB:MicroRNA)
RETURN mirnaA, r, mirnaB;

// Projeta a rede de microRNAs para armazenamento no catálogo de grafos
CALL gds.graph.project(
    'ProjectedNetwork',
    'MicroRNA',
    {
        IS_RELATED_TO: {
            orientation: 'UNDIRECTED',
            properties: ['commonMrnas']
        }
    }
)

// --- CENTRALIDADES ---
// Calcula a centralidade de grau dos nós
CALL gds.degree.stream('ProjectedNetwork')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).id AS mirnaid, score AS degree
ORDER BY degree DESC, mirnaid ASC;

// Calcula a centralidade de grau ponderada dos nós
CALL gds.degree.stream(
   'ProjectedNetwork',
   { relationshipWeightProperty: 'commonMrnas' }
)
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).id AS mirnaid, score AS weightedDegree
ORDER BY weightedDegree DESC, mirnaid ASC;

// Calcula a centralidade de intermediação dos nós
CALL gds.betweenness.stream('ProjectedNetwork')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).id AS mirnaid, score AS betweenness
ORDER BY betweenness DESC, mirnaid ASC;

// Calcula a centralidade de intermediação ponderada dos nós
CALL gds.betweenness.stream(
   'ProjectedNetwork',
   { relationshipWeightProperty: 'commonMrnas' }
)
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).id AS mirnaid, score AS weightedBetweenness
ORDER BY weightedBetweenness DESC, mirnaid ASC;

// Calcula a centralidade de autovetor dos nós
CALL gds.eigenvector.stream('ProjectedNetwork')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).id AS mirnaid, score AS eigenvector
ORDER BY eigenvector DESC, mirnaid ASC;

// Calcula a centralidade de autovetor ponderada dos nós
CALL gds.eigenvector.stream(
    'ProjectedNetwork',
    {
        maxIterations: 20,
        relationshipWeightProperty: 'commonMrnas' 
    }
)
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).id AS mirnaid, score AS weightedEigenvector
ORDER BY weightedEigenvector DESC, mirnaid ASC;

// Calcula a centralidade de proximidade dos nós
CALL gds.closeness.stream('ProjectedNetwork')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).id AS mirnaid, score AS closeness
ORDER BY closeness DESC, mirnaid ASC;

// Identifica os pontos de articulação da rede
CALL gds.articulationPoints.stream('ProjectedNetwork')
YIELD nodeId
RETURN gds.util.asNode(nodeId).id AS mirnaid
ORDER BY mirnaid ASC;

// Identifica as pontes da rede
CALL gds.bridges.stream('ProjectedNetwork')
YIELD from, to
RETURN gds.util.asNode(from).id AS from, gds.util.asNode(to).id AS to
ORDER BY from ASC, to ASC

// --- DETECÇÃO DE COMUNIDADES ---
// Calcula a quantidade de triângulos na rede
CALL gds.triangleCount.stream('ProjectedNetwork')
YIELD nodeId, triangleCount
RETURN gds.util.asNode(nodeId).id AS mirnaid, triangleCount
ORDER BY triangleCount ASC, mirnaid ASC;

// Calcula o máximo k-corte aproximado da rede
CALL gds.maxkcut.stream('ProjectedNetwork')
YIELD nodeId, communityId
RETURN gds.util.asNode(nodeId).id AS mirnaid, communityId
ORDER BY communityId ASC, mirnaid ASC;

// Calcula o máximo k-corte aproximado ponderado da rede
CALL gds.maxkcut.stream(
    'ProjectedNetwork',
    { relationshipWeightProperty: 'commonMrnas' }
)
YIELD nodeId, communityId
RETURN gds.util.asNode(nodeId).id AS mirnaid, communityId
ORDER BY communityId ASC, mirnaid ASC;
