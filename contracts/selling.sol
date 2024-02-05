
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Seeling_Contract {
    address public owner;
    address public buyer;
    uint public productPrice;
    bool public isProductSold;

    event ProductPurchased(address indexed buyer, uint productPrice);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only buyer can call this function");
        _;
    }

    modifier productNotSold() {
        require(!isProductSold, "Product has already been sold");
        _;
    }

    constructor(uint _productPrice) {
        owner = msg.sender;
        productPrice = _productPrice;
    }
//através da função setBuyer o proprietário do contrato vai poder definir o comprador.
    function setBuyer(address _buyer) external onlyOwner productNotSold {
        buyer = _buyer;
    }
//O comprador pode comprar o produto chamando a função purchaseProduct e enviando o valor do pagamento.
    function purchaseProduct() external payable onlyBuyer productNotSold {
        require(msg.value == productPrice, "Incorrect payment amount");
        isProductSold = true;
        emit ProductPurchased(buyer, productPrice);
    }
//O saldo pode ser retirado pelo proprietário após a compra ser concluída usando a função withdrawBalance.
    function withdrawBalance() external onlyOwner {
        require(isProductSold, "Product has not been sold yet");
        payable(owner).transfer(address(this).balance);
    }
}
