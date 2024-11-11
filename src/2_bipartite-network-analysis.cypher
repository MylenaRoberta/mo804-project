// --- CENTRALIDADES ---
// Calcula a centralidade de grau dos nós
CALL gds.degree.stream('BipartiteNetwork')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).id AS molecule, score AS degree
ORDER BY degree DESC, molecule ASC;

// Calcula a centralidade de intermediação dos nós
CALL gds.betweenness.stream('BipartiteNetwork')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).id AS molecule, score AS betweenness
ORDER BY betweenness DESC, molecule ASC;

// Calcula a centralidade de proximidade dos nós
CALL gds.closeness.stream('BipartiteNetwork')
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).id AS molecule, score AS closeness
ORDER BY closeness DESC, molecule ASC;

// Identifica os pontos de articulação da rede
CALL gds.articulationPoints.stream('BipartiteNetwork')
YIELD nodeId
RETURN gds.util.asNode(nodeId).id AS molecule
ORDER BY molecule ASC;

// Identifica as pontes da rede
CALL gds.bridges.stream('BipartiteNetwork')
YIELD from, to
RETURN gds.util.asNode(from).id AS from, gds.util.asNode(to).id AS to
ORDER BY from ASC, to ASC;

// --- DETECÇÃO DE COMUNIDADES ---
// Calcula a quantidade de componentes na rede
CALL gds.wcc.stream('BipartiteNetwork')
YIELD nodeId, componentId
RETURN gds.util.asNode(nodeId).id AS molecule, componentId
ORDER BY componentId ASC, molecule ASC;

// Calcula a quantidade de triângulos na rede
CALL gds.triangleCount.stream('BipartiteNetwork')
YIELD nodeId, triangleCount
RETURN gds.util.asNode(nodeId).id AS molecule, triangleCount
ORDER BY triangleCount DESC, molecule ASC;

// Calcula o coeficiente de clusterização local da rede
CALL gds.localClusteringCoefficient.stream('BipartiteNetwork')
YIELD nodeId, localClusteringCoefficient
RETURN gds.util.asNode(nodeId).id AS molecule, localClusteringCoefficient
ORDER BY localClusteringCoefficient DESC, molecule ASC;

// Calcula o coeficiente de clusterização global da rede
CALL gds.localClusteringCoefficient.stats('BipartiteNetwork')
YIELD averageClusteringCoefficient, nodeCount;