const BingoTest = artifacts.require("BingoTest");

contract("Integration tests", (accounts) => {
  let BingoTestInstance;

  before(async () => {
    BingoTestInstance = await BingoTest.deployed();
  });

  describe("0.BingoTest", async () => {
    it("1.should set numbers for bingo", async () =>{
        //Given
            let tx;

            let numbers = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]

        //When
            tx = await BingoTestInstance.addNumbersToRound(numbers, {from: accounts[0]});
            let round = await BingoTestInstance.getRound(0);
            console.log(round);
        //Then
            assert.equal(true, tx.receipt.status , "Transaction was unsuccessfull!");
    });
  });
});