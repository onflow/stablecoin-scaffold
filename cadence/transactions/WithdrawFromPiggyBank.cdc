import "FungibleToken"
import "EVMVMBridgedToken_2aabea2058b5ac2d339b163c6ab6f2b6d53aabed"
import "PiggyBank"

/// This transaction withdraws USDF tokens from the piggy bank and deposits them into the signer's USDF vault
transaction(amount: UFix64) {

    let piggyBankRef: &PiggyBank.PiggyBankVault
    let usdReceiver: &{FungibleToken.Receiver}

    prepare(signer: auth(BorrowValue) &Account) {

        // Borrow reference to the piggy bank
        self.piggyBankRef = signer.storage.borrow<&PiggyBank.PiggyBankVault>(
            from: PiggyBank.PiggyBankStoragePath
        ) ?? panic("Could not borrow reference to piggy bank. Make sure you have set up your piggy bank first.")

        // Borrow reference to the USDF vault receiver
        self.usdReceiver = signer.storage.borrow<&{FungibleToken.Receiver}>(
            from: /storage/EVMVMBridgedToken_2aabea2058b5ac2d339b163c6ab6f2b6d53aabedVault
        ) ?? panic("Could not borrow reference to USDF vault. Make sure you have set up your USDF vault first.")
    }

    execute {
        // Withdraw USDF tokens from piggy bank
        let tokens <- self.piggyBankRef.withdraw(amount: amount)

        // Deposit into signer's USDF vault
        self.usdReceiver.deposit(from: <-tokens)

        log("Successfully withdrew ".concat(amount.toString()).concat(" USDF tokens from piggy bank"))
    }
}
