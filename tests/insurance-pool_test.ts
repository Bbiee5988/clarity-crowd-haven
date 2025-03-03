import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

// [Previous tests remain unchanged]

Clarinet.test({
  name: "Ensures functions fail when pool is not initialized",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("insurance-pool", "contribute", [
        types.uint(1000000)
      ], wallet1.address)
    ]);

    assertEquals(block.receipts.length, 1);
    block.receipts[0].result.expectErr().expectUint(100); // err-not-initialized
  },
});

// [Additional test cases for new validations]
