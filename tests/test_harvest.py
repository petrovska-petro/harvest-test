#!/usr/bin/python3
from brownie import Wei


def test_harvest_swaps(
    harvest, chain, crv, cvx, three_crv, whale_crv, whale_cvx, whale_three_crv
):
    balance_pool_before = harvest.balanceOfPool()
    print(f"Balance in cvxCrvRewardsPool before: {balance_pool_before}")

    print(f"CRV={Wei(crv.balanceOf(harvest)).to('ether')}")
    print(f"CVX={Wei(cvx.balanceOf(harvest)).to('ether')}")
    print(f"3CRV={Wei(three_crv.balanceOf(harvest)).to('ether')}")

    harvested_tx = harvest.harvest()
    print(
        f'Total harvested swap: {Wei(harvested_tx.events["Tend"].values()[0]).to("ether")}'
    )
    # print(tx.call_trace())
    balance_pool_after = harvest.balanceOfPool()
    print(f"Balance in cvxCrvRewardsPool after: {Wei(balance_pool_after).to('ether')}")

    # one day ahead
    chain.sleep(24 * 60 * 60)
    chain.mine(1)

    harvested_tx_second = harvest.harvest()
    print(
        f'Total harvested swap: {Wei(harvested_tx_second.events["Tend"].values()[0]).to("ether")}'
    )
    # print(tx_with.call_trace())

    balance_pool_after_second = harvest.balanceOfPool()
    print(
        f"Balance in cvxCrvRewardsPool after: {Wei(balance_pool_after_second).to('ether')}"
    )


def test_harvest_direct(
    harvest_direct, chain, crv, cvx, three_crv, whale_crv, whale_cvx, whale_three_crv
):
    balance_pool_before = harvest_direct.balanceOfPool()
    print(f"Balance in cvxCrvRewardsPool before: {balance_pool_before}")

    print(f"CRV={Wei(crv.balanceOf(harvest_direct)).to('ether')}")
    print(f"CVX={Wei(cvx.balanceOf(harvest_direct)).to('ether')}")
    print(f"3CRV={Wei(three_crv.balanceOf(harvest_direct)).to('ether')}")

    harvested_tx = harvest_direct.harvest()
    print(
        f'Total harvested direct: {Wei(harvested_tx.events["Tend"].values()[0]).to("ether")}'
    )
    # print(tx.call_trace())
    balance_pool_after = harvest_direct.balanceOfPool()
    print(f"Balance in cvxCrvRewardsPool after: {Wei(balance_pool_after).to('ether')}")

    # one day ahead
    chain.sleep(24 * 60 * 60)
    chain.mine(1)

    harvested_tx_second = harvest_direct.harvest()
    print(
        f'Total harvested direct: {Wei(harvested_tx_second.events["Tend"].values()[0]).to("ether")}'
    )
    # print(tx_with.call_trace())

    balance_pool_after_second = harvest_direct.balanceOfPool()
    print(
        f"Balance in cvxCrvRewardsPool after: {Wei(balance_pool_after_second).to('ether')}"
    )
