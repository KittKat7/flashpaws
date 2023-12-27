# flashpaws

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Timeline
```mermaid
---
title: Alpha Timeline
---
flowchart TD
    a["✔️ Basic class"] --> basicPageUI
    subgraph basicPageUI["✔️ Basic Page UI"]
        b["✔️ Home Page/Overview"]
    end
    basicPageUI --> d
    subgraph d["✔️ Saving/loading in Hive"]
        d1["✔️ Read data from Hive"] --> d2
        d2["✔️ Write data to Hive"]
    end
    d --> cards
    subgraph cards[Cards]
        direction TB
        subgraph e["✔️ Ability to create cards"]
            direction TB
            e1["✔️ UI for creating card"] --> e2
            e2["✔️ Add card in memory"] --> e3
            e3["✔️ Save to Hive"]
        end
        e --> f
        subgraph f["✔️ Deleting card"]
            direction TB
            f1["✔️ UI for confirm delete"] --> f2
            f2["✔️ Remove card from memory and references"] --> f3
            f3["✔️ Remove card from Hive"]
        end
        f --> g
        subgraph g["🔜 Ability to modify cards"]
            direction TB
            g1[UI for modifying card] --> g2
            g2[Change card in memory and references] --> g3
            g3[Save to Hive]
        end
    end
    cards --> decks
    subgraph decks[Decks]
        direction TB
        subgraph h[Create deck]
            direction TB
            h1[UI for creating deck] --> h2
            h2[Add deck in memory] --> h3
            h3[Save to Hive]
        end
        h --> i
        subgraph i[Deleting deck]
            direction TB
            i1[UI for confirm delete] --> i2
            i2[Remove deck from mem and references] --> i3
            i3[Remove deck from Hive]
        end
        i --> j
        subgraph j[Ability to modify deck]
            direction TB
            j1[UI for modifying deck] --> j2
            j2[Change deck in memory and references] --> j3
            j3[Save to Hive]
        end
    end
    decks --> markdown
    subgraph markdown[Import/export]
        k[Export to Markdown] --> l
        l[Import from Markdown]
    end
    markdown --> additionalPageUI
    subgraph additionalPageUI["🔜 Additional Pages"]
        n["✔️ Review Page\n 🔜 Add long press capability to confidence buttons, will reset selection.\n 🔜 Remove ability to remove confidence rating by short clicking selected option.\n 🔜 make setting confidence update saved card data."] --> practicePage
        practicePage["✔️ Practice Page"] --> o
        o["Multitest Page"]
    end
```
