// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

// import "@truffle/Assert.sol";
// import "truffle/DeployedAddresses.sol";
import "../contracts/IndexFund.sol";

contract TestIndexFund {
  function testTemp() public {
    assert(true);

    // uint expected = 10000;

    // Assert.equal(meta.getBalance(tx.origin), expected, "Owner should have 10000 MetaCoin initially");
  }

  // function testInitialBalanceWithNewMetaCoin() {
  //   MetaCoin meta = new MetaCoin();

  //   uint expected = 10000;

  //   Assert.equal(meta.getBalance(tx.origin), expected, "Owner should have 10000 MetaCoin initially");
  // }
}