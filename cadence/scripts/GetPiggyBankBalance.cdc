import "PiggyBank"

/// This script returns the balance of USDF tokens in the piggy bank contract
access(all) fun main(): UFix64 {
    return PiggyBank.getBalance()
}
