import {
    Clarinet,
    Tx,
    Chain,
    Account,
    types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Can create a cooking session",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const block = chain.mineBlock([
            Tx.contractCall('chef-nest', 'create-session',
                [types.ascii("Italian Night"),
                 types.ascii("Pizza making session"),
                 types.uint(1640995200)],
                deployer.address
            )
        ]);
        
        block.receipts[0].result.expectOk().expectUint(1);
        
        const pointsResponse = chain.callReadOnlyFn(
            'chef-nest',
            'get-user-points',
            [types.principal(deployer.address)],
            deployer.address
        );
        pointsResponse.result.expectOk().expectUint(10);
    }
});

Clarinet.test({
    name: "Can join an existing session",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const wallet1 = accounts.get('wallet_1')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('chef-nest', 'create-session',
                [types.ascii("Italian Night"),
                 types.ascii("Pizza making session"),
                 types.uint(1640995200)],
                deployer.address
            )
        ]);
        
        block = chain.mineBlock([
            Tx.contractCall('chef-nest', 'join-session',
                [types.uint(1)],
                wallet1.address
            )
        ]);
        
        block.receipts[0].result.expectOk().expectBool(true);
        
        const pointsResponse = chain.callReadOnlyFn(
            'chef-nest',
            'get-user-points',
            [types.principal(wallet1.address)],
            wallet1.address
        );
        pointsResponse.result.expectOk().expectUint(5);
    }
});

Clarinet.test({
    name: "Can share and rate recipes",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('chef-nest', 'create-session',
                [types.ascii("Italian Night"),
                 types.ascii("Pizza making session"),
                 types.uint(1640995200)],
                deployer.address
            ),
            Tx.contractCall('chef-nest', 'share-recipe',
                [types.uint(1),
                 types.ascii("Margherita"),
                 types.ascii("Traditional Italian pizza...")],
                deployer.address
            ),
            Tx.contractCall('chef-nest', 'rate-session',
                [types.uint(1),
                 types.uint(5)],
                deployer.address
            )
        ]);
        
        block.receipts[1].result.expectOk().expectBool(true);
        block.receipts[2].result.expectOk().expectBool(true);
        
        const pointsResponse = chain.callReadOnlyFn(
            'chef-nest',
            'get-user-points',
            [types.principal(deployer.address)],
            deployer.address
        );
        pointsResponse.result.expectOk().expectUint(27); // 10 + 15 + 2
    }
});
