const keccak256 = require('keccak256');
const { ethers, arrayify} = require('ethers'); // Corrige a importação

// Função para gerar a Merkle Root e os proofs
function generateMerkleTree(addresses) {
  if (addresses.length === 0) return { root: '', proofs: [] };

  // Gera os nós folha (hash de cada endereço)
  let leafNodes = addresses.map((address) =>
    keccak256(address) // Gera o hash de cada endereço
  );

  const layers = [leafNodes]; // Array para armazenar as camadas da árvore

  // Constrói a árvore de Merkle
  while (leafNodes.length > 1) {
    const tempNodes = [];

    for (let i = 0; i < leafNodes.length; i += 2) {
      const left = leafNodes[i];
      const right = leafNodes[i + 1] ? leafNodes[i + 1] : left;

      // Concatena e hasheia os dois nós para formar o nó pai
      const parentNode = keccak256(Buffer.concat([left, right]));
      tempNodes.push(parentNode);
    }

    leafNodes = tempNodes;
    layers.push(leafNodes); // Adiciona a nova camada à árvore
  }

  // A raiz da árvore está na última camada
  const root = layers[layers.length - 1][0].toString('hex');

  // Função para gerar o proof de um endereço específico
  function getProof(index) {
    let proof = [];
    let currentIndex = index;

    // Percorre todas as camadas, exceto a última (a raiz)
    for (let i = 0; i < layers.length - 1; i++) {
      const layer = layers[i];

      // Verifica se o índice é par ou ímpar
      const pairIndex = currentIndex % 2 === 0 ? currentIndex + 1 : currentIndex - 1;

      // Se o par existir, adiciona-o ao proof
      if (pairIndex < layer.length) {
        proof.push(layer[pairIndex].toString('hex'));
      }

      // Atualiza o índice para a camada superior
      currentIndex = Math.floor(currentIndex / 2);
    }

    return proof;
  }

  // Gera o proof para cada endereço
  const proofs = addresses.map((_, index) => getProof(index));

  return { root, proofs };
}

// Exemplo de uso: Endereços que formarão as folhas da árvore
const addresses = [
  '0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC',
  '0x90F79bf6EB2c4f870365E785982E1f101E93b906',
  '0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65',
  '0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc'
];

// Gera a Merkle Tree e os proofs
const { root, proofs } = generateMerkleTree(addresses);

// Exibe a Merkle Root
console.log('Merkle Root:', root);

// Exibe cada endereço com seu respectivo leaf e proof
addresses.forEach((address, index) => {
  const leaf = keccak256(address).toString('hex');
  const proof = proofs[index];

  console.log(`\nAddress: ${address}`);
  console.log(`Leaf (hash): ${leaf}`);
  console.log(`Proof:`, proof);
});