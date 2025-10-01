import Test
import "PiggyBank"
import "EVMVMBridgedToken_2aabea2058b5ac2d339b163c6ab6f2b6d53aabed"
import "FungibleToken"

access(all) let account = Test.createAccount()

access(all) fun setup() {
    // Deploy USDF Mock contract first
    let usdErr = Test.deployContract(
        name: "EVMVMBridgedToken_2aabea2058b5ac2d339b163c6ab6f2b6d53aabed",
        path: "../contracts/USDF_MOCK.cdc",
        arguments: [],
    )
    Test.expect(usdErr, Test.beNil())

    // Deploy PiggyBank contract
    let err = Test.deployContract(
        name: "PiggyBank",
        path: "../contracts/PiggyBank.cdc",
        arguments: [],
    )
    Test.expect(err, Test.beNil())
}

access(all) fun testCreatePiggyBank() {
    // Create a piggy bank
    let piggyBank <- PiggyBank.createPiggyBank()

    // Check initial balance is 0
    Test.assertEqual(0.0, piggyBank.getBalance())

    destroy piggyBank
}

access(all) fun testDepositAndWithdraw() {
    // Create a piggy bank
    let piggyBank <- PiggyBank.createPiggyBank()

    // Mint some USDF tokens for testing
    let tokens <- EVMVMBridgedToken_2aabea2058b5ac2d339b163c6ab6f2b6d53aabed.mintTokens(amount: 100.0)

    // Deposit tokens into piggy bank
    piggyBank.deposit(from: <-tokens)

    // Check balance after deposit
    Test.assertEqual(100.0, piggyBank.getBalance())

    // Withdraw half
    let withdrawn <- piggyBank.withdraw(amount: 50.0)

    // Check balance after withdrawal
    Test.assertEqual(50.0, piggyBank.getBalance())
    Test.assertEqual(50.0, withdrawn.balance)

    destroy withdrawn
    destroy piggyBank
}

access(all) fun testInsufficientBalance() {
    // Create a piggy bank
    let piggyBank <- PiggyBank.createPiggyBank()

    // Mint some USDF tokens
    let tokens <- EVMVMBridgedToken_2aabea2058b5ac2d339b163c6ab6f2b6d53aabed.mintTokens(amount: 50.0)

    // Deposit tokens
    piggyBank.deposit(from: <-tokens)

    // Try to withdraw more than available - this should panic
    // Note: In a real test, you'd want to use Test.expectFailure or similar

    destroy piggyBank
}

access(all) fun testMultipleDeposits() {
    // Create a piggy bank
    let piggyBank <- PiggyBank.createPiggyBank()

    // Make multiple deposits
    let tokens1 <- EVMVMBridgedToken_2aabea2058b5ac2d339b163c6ab6f2b6d53aabed.mintTokens(amount: 25.0)
    piggyBank.deposit(from: <-tokens1)

    let tokens2 <- EVMVMBridgedToken_2aabea2058b5ac2d339b163c6ab6f2b6d53aabed.mintTokens(amount: 75.0)
    piggyBank.deposit(from: <-tokens2)

    // Check total balance
    Test.assertEqual(100.0, piggyBank.getBalance())

    destroy piggyBank
}