# trick_shot_game

## Nouns

- player
- character
- grabber / grabbee
- lifter / liftee

## Verbs

- grab
- ungrab
- hand
- throw
- release

## Mechancis

### Grab

- A time-locked temporary state where a character **grabs** another character.
- They either **hand** them off to their _liftee_ or **lift** them.
- Is triggered automatically if conditions are met.
```
if ((A is player) or (A in group of player)) and 
   ((A is not grabbing) and (None in group of A is grabbing)) and 
   (C is within range) 
{
    A grabs C
    {
        if A has liftee B
        {
            A ungrabs C
            B grabs C
         } else {
            A lifts C
         }
    }
}
```

### Force Grab
- An action where you a character forces their _lifter_ to release them and grabs them.
- Is triggered by a button if conditions are met.
```
if (A has lifter B) and
   (A force_grabs B) 
{
    B releases A
    A grabs B
}
```

### Lift
- A permanent state where a character is lifting another character and can throw them.
- Is triggered automatically after a grab if conditions are met.
```
if A lifts B
{
   A becomes B's lifter
   B becomes A's liftee
}
```

### Throw
- An action where a _lifter_ **throws** a _liftee_
- Is triggered by a button if conditions are met
```
if (A has liftee B) and
   (A throws)
{
    A releases B
    B gets launched
}
```
