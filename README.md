Solitaire clone written in zig

Todo
- Implement hidden cards
- Cant click and move hidden cards
- Can reveal hidden cards if last on stack with a click


Later
- Implement the draw pile
- Add the 4 top stacks to put cards into

DONE
- Load card spreadsheet DONE
- Create List of Card objects for each card in spreadsheet DONE
- Randomize list of cards DONE
- Load cards into the stacks DONE
- Just use the 7 card stacks for now to play with DONE

- Get nearest valid stack
    - Returns optional *Stack
        - if no valid stack
            - Return cards to orig stack
        - else
            - Add them to new stacK

- Add rules for moving cards between stacks
    - Alternate colors
    - Ascending numbers
    - Dont bother with hiding cards just yet
