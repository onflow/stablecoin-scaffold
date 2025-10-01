import "PiggyBank"

/// This script returns the balance of USDF tokens in a user's piggy bank
access(all) fun main(address: Address): UFix64 {

    let account = getAccount(address)

    // Borrow the public capability for the piggy bank
    let piggyBankRef = account.capabilities.borrow<&{PiggyBank.PublicPiggyBank}>(
        PiggyBank.PiggyBankPublicPath
    ) ?? panic("Could not borrow piggy bank reference for address ".concat(address.toString()))

    return piggyBankRef.getBalance()
}
