const BingoTest = artifacts.require("BingoTest");

module.exports = function (deployer, network, accounts) {
    if (deployer.network === "development") {

  deployer.then(async () => {
    let Instance = await deployer.deploy(BingoTest, accounts[8], {from: accounts[0]});
  });
}
};

