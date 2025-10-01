import Test

access(all) let account = Test.createAccount()

access(all) fun testContract() {
    let err = Test.deployContract(
        name: "PiggyBank",
        path: "../contracts/PiggyBank.cdc",
        arguments: [],
    )

    Test.expect(err, Test.beNil())
}