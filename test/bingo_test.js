const BingoTest = artifacts.require("BingoTest");

contract("Integration tests", (accounts) => {
  let BingoTestInstance;
  let tillRound = 50;
  let numbers = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]

  before(async () => {
    BingoTestInstance = await BingoTest.deployed();
  });

  describe("0.BingoTest", async () => {
    it("1.should set numbers for bingo", async () =>{
        //Given
            let tx;

        //When
            tx = await BingoTestInstance.addNumbersToRound(numbers, {from: accounts[0]});
            let round = await BingoTestInstance.getRound(0);
            // console.log(round);
        //Then
            assert.equal(true, tx.receipt.status , "Transaction was unsuccessfull!");
    });
    it("1.should set player numbers for bingo", async () =>{
      //Given
          let tx;
      //When
          tx = await BingoTestInstance.addPlayerBoard(tillRound, numbers, {from: accounts[0]});
          let board = await BingoTestInstance.getBoardForRound(tillRound, accounts[0]);
          // console.log(board);
      //Then
          assert.equal(true, tx.receipt.status , "Transaction was unsuccessfull!");
    });

    const testCases = [
      {
        testName: "check full row",
        checkIndex: 1
      },
      {
        testName: "check full column",
        checkIndex: 6
      },
      {
        testName: "check short row",
        checkIndex: 3
      },
      {
        testName: "check short column",
        checkIndex: 8
      },
      {
        testName: "check left right diagonal",
        checkIndex: 11
      },
      {
        testName: "check right left diagonal",
        checkIndex: 12
      },
    ]
    for (let c of testCases) {
      it(`shoud ${c.testName}`, async () => {
        //Given
          let tx;
        //When
          tx = await BingoTestInstance.bingoTest(c.checkIndex, tillRound, {from: accounts[0]});
        //Then
          assert.equal(true, tx.receipt.status , "Transaction was unsuccessfull!");
          await BingoTestInstance.addNumbersToRound(numbers, {from: accounts[0]});
      });
    }
     
  });
});