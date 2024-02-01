// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PurseContract{
    uint internal GracePeriodInterval;

    struct User{
        address userAdress;
        uint balance;
        //tempo após a solicitação de aprovação para movimentar fundos em que o usuário ainda pode movimentar seu dinheiro.
        uint GracePeriod;
        address payable guardian;
        bool approvedtomove;
    }

    mapping (address => User) users;

    constructor(uint GracePeriodIntervalInit){
        GracePeriodInterval = GracePeriodIntervalInit;
    }

    function externalpayable() external payable {
        //verifique se o usuário tem uma conta, caso contrário, rejeite.
        require(users[msg.sender].guardian != address(0));
        users[msg.sender].balance += msg.value;
    }

    function createUser(address payable guardian) public payable {
        require(users[msg.sender].guardian != address(0));
        User memory user = User(msg.sender, msg.value, 0, guardian, false);
        users[msg.sender] = user;
    }

    function transferEther(address payable to, uint256 amount) public {
        require(users[msg.sender].balance >= amount);
        to.transfer(amount);
        users[msg.sender].balance -= amount;
    }

    //o guardião suspeita que o usuário perdeu sua chave, inicia uma movimentação, mas deve esperar até que o período de carência termine.
    function guardianRequestToMoveFunds(address toMove) public {
        require(users[toMove].guardian == msg.sender);
        users[toMove].approvedtomove = true;
        /*o usuário pode movimentar seus fundos por conta própria antes do período de carência,
        isto é para proteger a movimentação maliciosa de fundos pelo guardião*/
        users[toMove].GracePeriod = block.timestamp + GracePeriodInterval;
    }
    //o usuário não movimentou fundos desde o período de carência, presumimos que ele perdeu suas chaves.
    function withdrawToGuardian(address toMove) public {
        require(users[toMove].guardian == msg.sender);
        require(users[toMove].GracePeriod < block.timestamp);
        users[toMove].guardian.transfer(users[toMove].balance);
        users[toMove].balance = 0;
        delete users[toMove];
    }

}




