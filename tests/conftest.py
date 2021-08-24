#!/usr/bin/python3

import pytest
from brownie import Wei

OPENZEPPELIN = "OpenZeppelin/openzeppelin-contracts@3.4.0"

CRV_ADDR = "0xD533a949740bb3306d119CC777fa900bA034cd52"
CVX_ADDR = "0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B"
THREE_CRV_ADDR = "0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490"


@pytest.fixture(scope="function", autouse=True)
def isolate(fn_isolation):
    # perform a chain rewind after completing each test, to ensure proper isolation
    # https://eth-brownie.readthedocs.io/en/v1.10.3/tests-pytest-intro.html#isolation-fixtures
    pass


@pytest.fixture(scope="module")
def harvest(HarvestSwaps, accounts):
    strategy_contract = HarvestSwaps.deploy({"from": accounts[0]})
    yield strategy_contract


@pytest.fixture(scope="module")
def harvest_direct(HarvestDirectMinting, accounts):
    strategy_contract = HarvestDirectMinting.deploy({"from": accounts[0]})
    yield strategy_contract


@pytest.fixture
def crv(interface):
    yield interface.ERC20(CRV_ADDR)


@pytest.fixture
def cvx(interface):
    yield interface.ERC20(CVX_ADDR)


@pytest.fixture
def three_crv(interface):
    yield interface.ERC20(THREE_CRV_ADDR)


@pytest.fixture
def whale_crv(accounts, crv, harvest, harvest_direct):
    crv_amount = Wei("3446 ether")
    whale_crv = accounts.at("0x687F7A828f3bb959F76BEAFfd34E998D63FEEe72", force=True)
    crv.transfer(harvest, crv_amount, {"from": whale_crv})
    crv.transfer(harvest_direct, crv_amount, {"from": whale_crv})
    yield whale_crv


@pytest.fixture
def whale_cvx(accounts, cvx, harvest, harvest_direct):
    cvx_amount = Wei("1281 ether")
    whale_cvx = accounts.at("0x858341666309F4328778EAb017C8065ae8DBAC19", force=True)
    cvx.transfer(harvest, cvx_amount, {"from": whale_cvx})
    cvx.transfer(harvest_direct, cvx_amount, {"from": whale_cvx})
    yield whale_cvx


@pytest.fixture
def whale_three_crv(accounts, three_crv, harvest, harvest_direct):
    threee_crv_amount = Wei("1997 ether")
    whale_three_crv = accounts.at(
        "0xA49b7ae3dB1A62E78245aa732E045dAc922eb183", force=True
    )
    three_crv.transfer(harvest, threee_crv_amount, {"from": whale_three_crv})
    three_crv.transfer(harvest_direct, threee_crv_amount, {"from": whale_three_crv})
    yield whale_three_crv
