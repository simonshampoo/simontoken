const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SimonToken", function () {
  it("should mint one billion $IMON tokens", async function () {
    const SimonToken = await ethers.getContractFactory("SimonToken");
    const [owner] = await ethers.getSigners(); 
    const simontoken = await SimonToken.deploy("SimonToken", "IMON", 1000000000000000000000000000);
    await simontoken.deployed();
    expect(await greeter.greet()).to.equal("Hello, world!");

    const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // wait until the transaction is mined
    await setGreetingTx.wait();

    expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
