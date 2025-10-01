import "PiggyBank"

/// This transaction sets up a PiggyBank vault for the signer's account.
/// It creates the piggy bank, saves it to storage, and creates the necessary public capability.
transaction() {

    prepare(signer: auth(BorrowValue, IssueStorageCapabilityController, PublishCapability, SaveValue) &Account) {

        // Check if account already has a piggy bank
        if signer.storage.borrow<&PiggyBank.PiggyBankVault>(from: PiggyBank.PiggyBankStoragePath) != nil {
            log("Account already has a piggy bank set up")
            return
        }

        // Create a new piggy bank
        let piggyBank <- PiggyBank.createPiggyBank()

        // Save the piggy bank to storage
        signer.storage.save(<-piggyBank, to: PiggyBank.PiggyBankStoragePath)

        // Create and publish public capability
        let piggyBankCap = signer.capabilities.storage.issue<&{PiggyBank.PublicPiggyBank}>(
            PiggyBank.PiggyBankStoragePath
        )
        signer.capabilities.publish(piggyBankCap, at: PiggyBank.PiggyBankPublicPath)

        log("PiggyBank setup completed successfully")
    }

    execute {
        log("Transaction completed")
    }
}
