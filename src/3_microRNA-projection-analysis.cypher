// --- CENTRALIDADES ---
// Calcula a centralidade de grau dos nós
CALL gds.degree.stream('ProjectedNetwork')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).id AS miR, score AS degree
ORDER BY degree DESC, miR ASC;

// Calcula a centralidade de grau ponderada dos nós
CALL gds.degree.stream(
   'ProjectedNetwork',
   { relationshipWeightProperty: 'commonMrnas' }
)
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).id AS miR, score AS weightedDegree
ORDER BY weightedDegree DESC, miR ASC;

// Calcula a centralidade de intermediação dos nós
CALL gds.betweenness.stream('ProjectedNetwork')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).id AS miR, score AS betweenness
ORDER BY betweenness DESC, miR ASC;

// Calcula a centralidade de intermediação ponderada dos nós
CALL gds.betweenness.stream(
   'ProjectedNetwork',
   { relationshipWeightProperty: 'commonMrnas' }
)
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).id AS miR, score AS weightedBetweenness
ORDER BY weightedBetweenness DESC, miR ASC;

// Calcula a centralidade de proximidade dos nós
CALL gds.closeness.stream('ProjectedNetwork')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).id AS miR, score AS closeness
ORDER BY closeness DESC, miR ASC;

// Identifica os pontos de articulação da rede
CALL gds.articulationPoints.stream('ProjectedNetwork')
YIELD nodeId
RETURN gds.util.asNode(nodeId).id AS miR
ORDER BY miR ASC;

// Identifica as pontes da rede
CALL gds.bridges.stream('ProjectedNetwork')
YIELD from, to
RETURN gds.util.asNode(from).id AS from, gds.util.asNode(to).id AS to
ORDER BY from ASC, to ASC

// --- DETECÇÃO DE COMUNIDADES ---
// Calcula a quantidade de componentes na rede
CALL gds.wcc.stream('ProjectedNetwork')
YIELD nodeId, componentId
RETURN gds.util.asNode(nodeId).id AS miR, componentId
ORDER BY componentId ASC, miR ASC;

// Calcula a quantidade de triângulos na rede
CALL gds.triangleCount.stream('ProjectedNetwork')
YIELD nodeId, triangleCount
RETURN gds.util.asNode(nodeId).id AS miR, triangleCount
ORDER BY triangleCount ASC, miR ASC;

// Calcula o coeficiente de clusterização local da rede
CALL gds.localClusteringCoefficient.stream('ProjectedNetwork')
YIELD nodeId, localClusteringCoefficient
RETURN gds.util.asNode(nodeId).id AS miR, localClusteringCoefficient
ORDER BY localClusteringCoefficient DESC, miR ASC;

// Calcula o coeficiente de clusterização global da rede
CALL gds.localClusteringCoefficient.stats('ProjectedNetwork')
YIELD averageClusteringCoefficient, nodeCount;

// Identifica as comunidades da rede
CALL gds.louvain.stream('ProjectedNetwork')
YIELD nodeId, communityId
RETURN gds.util.asNode(nodeId).id AS miR, communityId
ORDER BY communityId ASC, miR ASC;

// --- SELEÇÃO DAS ARESTAS MAIS RELEVANTES ---
// Mostra as interações da rede acompanhadas de peso e da mediana 
MATCH ()-[r:IS_RELATED_TO]-()
WITH apoc.agg.median(r.commonMrnas) AS median
MATCH (mirnaA:MicroRNA)-[r:IS_RELATED_TO]-(mirnaB:MicroRNA)
RETURN mirnaA.id AS from, mirnaB.id AS to, r.commonMrnas AS commonMrnas, median
ORDER BY commonMrnas DESC;

// Filtra as arestas mais relevantes da rede
MATCH ()-[r:IS_RELATED_TO]->()
WITH apoc.agg.median(r.commonMrnas) AS median
MATCH (mirnaA:MicroRNA)-[r:IS_RELATED_TO]->(mirnaB:MicroRNA)
WHERE r.commonMrnas > median
WITH mirnaA, mirnaB, r
MERGE (mirnaA)-[sr:IS_STRONGLY_RELATED_TO]-(mirnaB)
SET sr.commonMrnas = r.commonMrnas;

// Mostra as interações mais relevantes da rede
MATCH (mirnaA:MicroRNA)-[r:IS_STRONGLY_RELATED_TO]-(mirnaB:MicroRNA)
RETURN mirnaA.id AS from, mirnaB.id AS to, r.commonMrnas AS commonMrnas
ORDER BY commonMrnas DESC;

// Projeta a rede de microRNAs com "relações relevantes" para armazenamento no catálogo de grafos
CALL gds.graph.project(
   'ProjectedRelevantNetwork',
   'MicroRNA',
   {
      IS_STRONGLY_RELATED_TO: {
         orientation: 'UNDIRECTED',
         properties: ['commonMrnas']
      }
   }
)

// Identifica as comunidades da rede relevate
CALL gds.louvain.stream('ProjectedRelevantNetwork')
YIELD nodeId, communityId
RETURN gds.util.asNode(nodeId).id AS miR, communityId
ORDER BY communityId ASC, miR ASC;