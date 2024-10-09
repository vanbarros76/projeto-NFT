// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol"; // fornece controle sobre quem pode chamar funções restritas, como a função withdraw, que apenas o proprietário pode executar.


contract CollectionNFT is ERC721, ERC721Enumerable, Ownable {
    uint256 private _nextTokenId; // Mantém o controle dos IDs dos tokens a serem cunhados.
    uint256 public constant MAX_SUPPLY = 10000; // Limite de NFTs a serem cunhados.
    uint256 public constant PRICE = 0.05 ether; //O URI base para a coleção de NFTs, que pode ser usado para recuperar os metadados de cada NFT.
    string private _baseTokenURI; // Retorna o URI base para os tokens, substituindo o comportamento padrão do ERC721.

    error InsufficientValue(uint256 enviado, uint256 requerido);
    error MaxLimitReached(uint256 totalSupply, uint256 maxSupply);

    event BaseURIChanged(string newBaseURI); // Notifica quando o URI base é alterado

    // Realiza a cunhagem segura do NFT, verificando se o valor enviado é suficiente e se o limite de supply foi atingido.
    constructor(string memory baseURI) ERC721("CollectionNFT", "CNFT") Ownable(msg.sender) {
        _baseTokenURI = baseURI;
    }

    // Função para atualizar o baseURI, apenas o proprietário pode chamar
    function setBaseURI(string memory baseURI) public onlyOwner { 
        _baseTokenURI = baseURI;
    }

    
    // Sobrescreve a função baseURI do ERC721 para retornar o baseTokenURI atual
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    // São usados para reverter a transação se o valor pago for insuficiente ou se o limite de NFTs já tiver sido atingido.
    function safeMint(address to) public payable {
        if (msg.value < PRICE) {
            revert InsufficientValue({
                enviado: msg.value,
                requerido: PRICE
            });
        }
        if (totalSupply() >= MAX_SUPPLY) {
            revert MaxLimitReached({
                totalSupply: totalSupply(),
                maxSupply: MAX_SUPPLY
            });
        }
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }

    function withdraw() public onlyOwner { // Permite ao proprietário retirar os fundos acumulados com as vendas dos NFTs.
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
    }

   
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // Adicionando a função _increaseBalance para resolver o conflito de erro quando ocorre do contrato estar
    // herdando de duas classes base (ERC721 e ERC721Enumerable) que definem a função _increaseBalance com a mesma assinatura. 
    function _increaseBalance(address account, uint128 amount) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, amount);
    }

    // Adicionando a função _update para resolver conflito de herança
    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }
}

