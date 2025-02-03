import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensures pool can be initialized only once",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const deployer = accounts.get("deployer")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("insurance-pool", "initialize", [
        types.ascii("Test Pool"),
        types.uint(1000000),
        types.uint(10000000),
        types.principal(deployer.address)
      ], deployer.address)
    ]);

    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    block.receipts[0].result.expectOk().expectBool(true);
  },
});

Clarinet.test({
  name: "Ensures claims can be filed and voted on",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet1 = accounts.get("wallet_1")!;
    const wallet2 = accounts.get("wallet_2")!;

    let block = chain.mineBlock([
      Tx.contractCall("insurance-pool", "file-claim", [
        types.uint(1000000),
        types.ascii("Test Claim")
      ], wallet1.address),
      Tx.contractCall("insurance-pool", "vote-on-claim", [
        types.uint(0),
        types.bool(true)
      ], wallet2.address)
    ]);

    assertEquals(block.receipts.length, 2);
    block.receipts[0].result.expectOk().expectUint(0);
    block.receipts[1].result.expectOk().expectBool(true);
  },
});
