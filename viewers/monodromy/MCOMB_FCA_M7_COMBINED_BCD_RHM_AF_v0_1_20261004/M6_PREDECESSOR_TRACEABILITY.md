# Acceptance map

| Requirement | Implementation | Verification |
|---|---|---|
| W1 collision / two histories | history-core derive/fold | W1 exact and browser real-source fixtures |
| W2 binomial row | count recurrence | W2 and 180 independent enumeration/folding cases |
| Atom wraps and repeated actions | definition ATOM | atom core and replay tests |
| Zero steps and loops | original letter alphabet | singleton and atom zero-step tests |
| Visible independent caps | tree/count statuses | node, cell, operation and browser truncation checks |
| Count prime distinct from q | options/recurrence | prime validation, reduced-exact comparison, browser parity |
| Complete source replay | history-packet | nested gates and rehashed forgeries |
| Stale/held/cancel guards | history-ui worker tickets | real-browser delayed responses, rejected imports and exports |
| M5 O1 larger graphs | independentGraph/clique test | 100 graphs, 14..36 vertices |
| M5 O2 stopping branch | common advance/searchResult | controlled one-step unresolved search |
| M5 O3 explicit integer lifts | representativeComparison | signed and even tie fixtures |
| Preservation | verify inventories / seal pins | full pre- and post-seal suites |

Machine receipts supply actual PASS/FAIL and counts. Random subcases are not double-counted as top-level groups.
