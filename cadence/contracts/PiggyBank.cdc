import "FungibleToken"
import "EVMVMBridgedToken_2aabea2058b5ac2d339b163c6ab6f2b6d53aabed"

/// PiggyBank is a simple contract that allows users to store USDF tokens
/// Users can deposit USDF tokens into their piggy bank and withdraw them later
access(all) contract PiggyBank {

    /// Events
    access(all) event PiggyBankCreated(owner: Address)
    access(all) event Deposited(owner: Address, amount: UFix64)
    access(all) event Withdrawn(owner: Address, amount: UFix64)

    /// Storage paths
    access(all) let PiggyBankStoragePath: StoragePath
    access(all) let PiggyBankPublicPath: PublicPath

    /// Public interface for reading piggy bank balance
    access(all) resource interface PublicPiggyBank {
        access(all) fun getBalance(): UFix64
    }

    /// PiggyBankVault resource stores USDF tokens
    access(all) resource PiggyBankVault: PublicPiggyBank {

        /// The vault that holds USDF tokens
        access(self) var vault: @{FungibleToken.Vault}

        init() {
            // Create an empty USDF vault
            self.vault <- EVMVMBridgedToken_2aabea2058b5ac2d339b163c6ab6f2b6d53aabed.createEmptyVault(
                vaultType: Type<@EVMVMBridgedToken_2aabea2058b5ac2d339b163c6ab6f2b6d53aabed.Vault>()
            )
        }

        /// Deposit USDF tokens into the piggy bank
        access(all) fun deposit(from: @{FungibleToken.Vault}) {
            let amount = from.balance
            self.vault.deposit(from: <-from)

            emit Deposited(owner: self.owner?.address ?? panic("No owner"), amount: amount)
        }

        /// Withdraw USDF tokens from the piggy bank
        access(all) fun withdraw(amount: UFix64): @{FungibleToken.Vault} {
            pre {
                amount > 0.0: "Withdrawal amount must be greater than zero"
                amount <= self.vault.balance: "Insufficient balance in piggy bank"
            }

            let withdrawn <- self.vault.withdraw(amount: amount)

            emit Withdrawn(owner: self.owner?.address ?? panic("No owner"), amount: amount)

            return <-withdrawn
        }

        /// Get the current balance in the piggy bank
        access(all) fun getBalance(): UFix64 {
            return self.vault.balance
        }
    }

    /// Create a new piggy bank vault
    access(all) fun createPiggyBank(): @PiggyBankVault {
        return <-create PiggyBankVault()
    }

    init() {
        self.PiggyBankStoragePath = /storage/PiggyBankVault
        self.PiggyBankPublicPath = /public/PiggyBankVault
    }
}