# Harvest isolation test

Command to run: 

 ```bash
 brownie test --network mainnet-fork tests/test_harvest.py -s --gas
 ```

 Console data output:
 
 ```bash
    tests/test_harvest.py::test_harvest_swaps
        Balance in cvxCrvRewardsPool before: 0
        CRV=3446.000000000000000000
        CVX=1281.000000000000000000
        3CRV=1997.000000000000000000
        Total harvested swap: 8391.894985790290317441
        Balance in cvxCrvRewardsPool after: 7552.705487211261285697
        Total harvested swap: 11.979780078399299410
        Balance in cvxCrvRewardsPool after: 7563.487289281820655166

    tests/test_harvest.py::test_harvest_direct
        Balance in cvxCrvRewardsPool before: 0
        CRV=3446.000000000000000000
        CVX=1281.000000000000000000
        3CRV=1997.000000000000000000
        Total harvested direct: 8316.161044440466173956
        Balance in cvxCrvRewardsPool after: 7484.544939996419556561
        Total harvested direct: 11.772954665925690751
        Balance in cvxCrvRewardsPool after: 7495.140599195752678237
 ```

 Gas profile output:

 ```bash
  HarvestDirectMinting <Contract>
   ├─ constructor -  avg: 1339755  avg (confirmed): 1339755  low: 1339755  high: 1339755
   └─ harvest     -  avg:  530625  avg (confirmed):  530625  low:  473545  high:  587706
HarvestSwaps <Contract>
   ├─ constructor -  avg: 1365100  avg (confirmed): 1365100  low: 1365100  high: 1365100
   └─ harvest     -  avg:  627613  avg (confirmed):  627613  low:  570533  high:  684694
 ```
