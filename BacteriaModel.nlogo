__includes ["sxl-utils.nls"]
extensions [sound]

;; Declaring all breeds
breed [antibacterias antibacteria]
breed [bacterias1 bacteria1]
breed [bacterias2 bacteria2]
breed [bacterias3 bacteria3]

globals [
  bacteria-total ; Counters
  dead-bacteria
  dead-antibacteria

  no-dosage-color   ;
  low-dosage-color
  medium-dosage-color
  high-dosage-color
  highest-dosage-color

  bacteria-t1-base-color
  bacteria-t2-base-color
  bacteria-t3-base-color
  antibacteria-base-color
]

;; Bacteria with membrane resistance trait, increased rate of resistance giving greater survivability (vancomycin-resistant Enterococcus )
bacterias1-own [
  reproduction-rate
  base-resistance
  membrane-resistance
]

;; Bacteria with undetectability trait, reducing chance of a kill check
bacterias2-own [
  reproduction-rate
  base-resistance
  detectability
]

;; Bacteria with enzyme production trait, chance of deactivating the antibiotic
bacterias3-own [
  reproduction-rate
  base-resistance
  enzyme-production
]

;; Antibacteria own a single property, whether they are active or inactive
antibacterias-own [
  isActive
]

;; Patches will hold two values, used to determine if there is bacteria/or antibacteria on the current patch
patches-own [
  zone
  my-antibacteria
  my-bacteria
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  setup procedures ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  setup-globals

  setup-dosage-area
  setup-shapes
  setup-bacteria
  setup-antibacteria

  reset-ticks
end

;; Giving all of the globals initial values
to setup-globals
  set bacteria-total 0
  set dead-bacteria 0
  set dead-antibacteria 0

  set no-dosage-color gray - 5
  set low-dosage-color gray - 1
  set medium-dosage-color gray
  set high-dosage-color gray + 1
  set highest-dosage-color gray + 2
  set bacteria-t1-base-color blue
  set bacteria-t2-base-color yellow
  set bacteria-t3-base-color red
  set antibacteria-base-color [57 255 20]
end

;; Creating the dosage area, assigning colors and zones to create the borders of each dosage area
;  Assign the values to patches from left to right
to setup-dosage-area
  ask patches with [pxcor < -18] [
    set pcolor no-dosage-color
    set zone "NO"
  ]

  ask patches with [pxcor >= -18 and pxcor < -6] [
    set pcolor low-dosage-color
    set zone "LOW"
  ]

  ask patches with [pxcor >= -6 and pxcor < 6] [
    set pcolor medium-dosage-color
    set zone "MEDIUM"
  ]

  ask patches with [pxcor >= 6 and pxcor < 18] [
    set pcolor high-dosage-color
    set zone "HIGH"
  ]

  ask patches with [pxcor >= 18] [
    set pcolor highest-dosage-color
    set zone "HIGHEST"
  ]

  ask patches [set my-bacteria nobody]
end

;; Setting the default shapes for each of the bacteria and antibacterias, these will be used throughout the program
to setup-shapes
  set-default-shape bacterias1 "bacteria"
  set-default-shape bacterias2 "bacteria"
  set-default-shape bacterias3 "bacteria"
  set-default-shape antibacterias "antibacteria-v2"
end

;; Creates the first wave of bacteria to be used at the start of the program
to setup-bacteria
  ; Use the borders created by setup-dosage-area to spawn the starting bacteria
  ; The concentration is determined by a slider which is part of the interface
  ; Increase bacteria-total and living-bacteria for each bacteria created
  ask patches with [zone = "NO"] [
    if (trigger bacteria-concentration%) [
      if (trigger bacteria-t1-percentage%) [
        sprout-bacterias1 1 [
          let this-bacteria self
          set color bacteria-t1-base-color
          set membrane-resistance 1
          set reproduction-rate bacteria-t1-reproduction-rate
          set my-bacteria this-bacteria
        ]
        set bacteria-total bacteria-total + 1
      ]

      if (trigger bacteria-t2-percentage%) [
        sprout-bacterias2 1 [
          let this-bacteria self
          set color bacteria-t2-base-color
          set reproduction-rate bacteria-t2-reproduction-rate
          set my-bacteria this-bacteria
        ]
        set bacteria-total bacteria-total + 1
      ]

      if (trigger bacteria-t3-percentage%) [
        sprout-bacterias3 1 [
          let this-bacteria self
          set color bacteria-t3-base-color
          set reproduction-rate bacteria-t3-reproduction-rate
          set my-bacteria this-bacteria
        ]
        set bacteria-total bacteria-total + 1
      ]
    ]
  ]
end

;; Create each wave of antibacteria
;  Each area is represented by the zone, with increasing concentration the further right the areas are
;  Sliders are used to assign the concentration percentage to each zone, this will directly influence how many antibiotics will spawn,
;  Ignore zone "NO" as this area is strictly for bacteria to begin multiplying
to setup-antibacteria
  ask patches with [zone = "LOW"] [
    if (trigger low-concentration%) [
      sprout-antibacterias 1 [
        set isActive true
        set color antibacteria-base-color
      ]
      set my-antibacteria self
    ]
  ]

  ask patches with [zone = "MEDIUM"] [
    if (trigger medium-concentration%) [
      sprout-antibacterias 1 [
        set isActive true
        set color antibacteria-base-color
      ]
      set my-antibacteria self
    ]
  ]

  ask patches with [zone = "HIGH"] [
    if (trigger high-concentration%) [
      sprout-antibacterias 1 [
        set isActive true
        set color antibacteria-base-color
      ]
      set my-antibacteria self
    ]
  ]

  ask patches with [zone = "HIGHEST"] [
    if (trigger highest-concentration%) [
      sprout-antibacterias 1 [
        set isActive true
        set color antibacteria-base-color
      ]
      set my-antibacteria self
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; runtime procedures ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go
  ask bacterias1 [ can-reproduce? ]
  ask bacterias2 [ can-reproduce? ]
  ask bacterias3 [ can-reproduce? ]
  ask antibacterias [
    if move-antibacteria [ move-antibacterias ]
    perform-kill-check
  ]
  tick
end

;; Called at the start of ever tick to determine collision outcomes between bacteria and antibacteria,
;  Calls necessary procedures pertaining to the bacterias unique trait to determine outcomes
to perform-kill-check
  let this-antibacteria self
  if (isActive) [
    if (bacterias1-here != nobody) [
      ask bacterias1-here [ if (is-dead base-resistance) [ bacteria-death ] ]
    ]

    if (bacterias2-here != nobody) [
      ask bacterias2-here [
        if (is-detected detectability) [ if (is-dead base-resistance) [ bacteria-death ] ]
      ]
    ]

    if (bacterias3-here != nobody) [
      ask bacterias3-here [
        ifelse (deactivate-anti enzyme-production) [
          antibacteria-death myself
        ] [ if (is-dead base-resistance) [ bacteria-death ] ]
      ]
    ]
  ]
end

;; Used to move the antibacteria within their respective zones,
;  The antibacteria have a 20% chance of moving
to move-antibacterias
  let %antis 0.2 ; creating a local variable which represents the 20% of antibacteria
  let n count antibacterias

  ; Multiplies total count of antibacteria by the 0.2 modifier, thus selecting 20% of antibacteria
  ask (n-of(%antis * n) antibacterias) [
    let this-antibacteria self
    if (not is-active this-antibacteria) [ stop ] ; if the antibacteria selected has been deactivated, it cannot move

    ; Create local variable representing current zone,
    ; Target one of the neighboring patches within the respective zone if they don't already have an antibacteria on them
    ; Give them 20% chance of movement
    let this-patch-zone zone
    let target one-of neighbors with [zone = this-patch-zone]
    if (target != nobody and not any? antibacterias-on target) [
      if (trigger 20) [
        move-to target
      ]
    ]
  ]
end

;; Check the area to see if the current bacteria is capable of reproducing
;  There must be a neighboring patch with no bacteria on it
;  If it can reproduce, call the bacteria-reproduce function and provide it the bacterias unique trait, base resistance, and color
to can-reproduce?
  let this-bacteria self
  let this-bacteria-color color

  if any? neighbors with [my-bacteria = nobody] [
    if (breed = bacterias1) [ if (trigger reproduction-rate) [ bacteria-reproduce membrane-resistance base-resistance this-bacteria-color ] ]

    if (breed = bacterias2) [ if (trigger reproduction-rate) [ bacteria-reproduce detectability base-resistance this-bacteria-color ] ]

    if (breed = bacterias3) [ if (trigger reproduction-rate) [ bacteria-reproduce enzyme-production base-resistance this-bacteria-color ] ]
  ]
end

;; Contains all logic for bacteria reproduction
;  Perform a check on the area to see if there is a neighboring patch with bacteria on it,
;  Check the breed of bacteria, uses hatch to duplicate itself and give the new bacteria the same values as itself with little modification,
;  Modifiy the bacterias unique-trait by increasing or decreasing, used to represent evolution and regression,
;  Adjust the color based on whether the bacteria evolved or regressed,
;  Move the new bacteria to one of the empty neighbouring patches
to bacteria-reproduce [unique-trait resistance bacteria-color]
  let this-bacteria self
  let available-patches neighbors with [my-bacteria = nobody] ; agent set of neighboring patches without any bacteria

  if any? available-patches [
    hatch 1 [
      if (breed = bacterias1) [
        let current-resistance membrane-resistance
        set membrane-resistance (unique-trait + (growth-sign membrane-resistance-stat-growth)) ; Call to growth-sign to determine evolution/regression
        set base-resistance (resistance + (growth-sign base-resistance-stat-growth)) + membrane-resistance

        ifelse (membrane-resistance > current-resistance) [
          set color (color + random-float 1)
        ] [ set color (color - random-float 1) ]
      ]

      if (breed = bacterias2) [
        let current-detectability detectability
        set detectability (unique-trait + (growth-sign detectability-stat-growth))
        set base-resistance (resistance + (growth-sign base-resistance-stat-growth))

        ifelse (detectability > current-detectability) [
          set color (color + random-float 1)
        ] [ set color (color - random-float 1) ]
      ]

      if (breed = bacterias3) [
        let current-enzyme-production enzyme-production
        set enzyme-production (unique-trait + (growth-sign enzyme-production-stat-growth))
        set base-resistance (resistance + (growth-sign base-resistance-stat-growth))
        ifelse (enzyme-production > current-enzyme-production) [
          set color (color + random-float 1)
        ] [ set color (color - random-float 1) ]
      ]

      let target-patch one-of available-patches
      ask target-patch [ set my-bacteria this-bacteria ]
      set heading towards target-patch
      fd 1
      set bacteria-total bacteria-total + 1
    ]
  ]
end

;; Reset the sliders to their default values
to reset-sliders
  set low-concentration% 10
  set medium-concentration% 25
  set high-concentration% 50
  set highest-concentration% 75

  set bacteria-concentration% 45
  set bacteria-t1-percentage% 15
  set bacteria-t2-percentage% 15
  set bacteria-t3-percentage% 15

  set bacteria-t1-reproduction-rate 50
  set bacteria-t2-reproduction-rate 50
  set bacteria-t3-reproduction-rate 50

  set membrane-resistance-stat-growth 0.5
  set detectability-stat-growth 0.5
  set enzyme-production-stat-growth 0.5

  set base-resistance-stat-growth 1
  set evolution-chance 50
  set regression-chance 50
end

;; Called when a bacteria is successfully killed
to bacteria-death
  let this-bacteria self
  set my-bacteria nobody ; set current patch value to nobody
  set dead-bacteria dead-bacteria + 1
  die
end

;; Called when an antibacteria is deactivated
;  Set color to white and set isActive to false to represent deactivation
to antibacteria-death [me]
  let this-antibacteria me
  ask this-antibacteria [
    set color white
    set isActive false
  ]
  set dead-antibacteria dead-antibacteria + 1
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;      reporters     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Check if the antibacteria provided has been deactivated or not
to-report is-active [me]
  let this-antibacteria me
  ifelse (isActive = true) [ report true ] [ report false ]
end

;; Discontinued reporter function
;; Compare the bacterias membrane resistance trait against the randomly generated number,
;  If true, and is-dead check is performed,
;  If false, is-dead check is avoided
;to-report is-entered [unique-trait]
;  report random 100 > unique-trait
;end

;; Compare the bacterias detectability trait with modifier against a randomly generated number,
;  If the check returns true, an is-dead check must then be performed,
;  If the check returns false, it avoids the is-dead check and survives that tick
to-report is-detected [unique-trait]
  report random 100 > unique-trait
end

;; Compare the bacterias enzyme-production trait against the randomly generated number,
;  If the number is higher, the antibacteria here is deactivated,
;  If the number is lower, the is-dead check is performed on the bacteria
to-report deactivate-anti [unique-trait]
  report random 100 < unique-trait
end

;; Compare the bacteria's base resistance against the randomly generated number,
;  If it's lower than the randomly generated number, it dies,
;  If it's higher, it survives
to-report is-dead [resistance]
  report random 100 > resistance
end

;; Used to flip the sign on a value to cause a bacteria to evolve or regress
to-report growth-sign [val]
  ifelse (trigger evolution-chance) [ report 0 + val ] [ifelse (trigger regression-chance) [ report 0 - val ] [ report 0 ] ]
end

to-report reached-immunity
  ifelse ((count bacterias1 with [base-resistance >= 100]) > 0) [report true] [report false]
end

to-report reached-zone-highest1
  ifelse (count bacterias1-on patches with [zone = "HIGHEST"] != 0) [ report true ] [ report false ]
end

to-report zone-reached
  ifelse ((count bacterias1-on patches with [pcolor = medium-dosage-color]) != 0) [ report true ] [
    ifelse ((count bacterias2-on patches with [pcolor = medium-dosage-color]) != 0) [ report true ] [
      ifelse ((count bacterias3-on patches with [pcolor = medium-dosage-color]) != 0) [ report true ] [ report false ]
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
410
10
1109
710
-1
-1
11.33
1
10
1
1
1
0
0
0
1
-30
30
-30
30
0
0
1
minutes
30.0

BUTTON
4
10
67
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
70
10
133
43
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
136
10
205
43
repeat
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
4
78
206
111
highest-concentration%
highest-concentration%
0
100
75.0
1
1
NIL
HORIZONTAL

SLIDER
4
114
206
147
high-concentration%
high-concentration%
0
75
50.0
1
1
NIL
HORIZONTAL

SLIDER
4
150
206
183
medium-concentration%
medium-concentration%
0
50
25.0
1
1
NIL
HORIZONTAL

SLIDER
4
186
206
219
low-concentration%
low-concentration%
0
25
10.0
1
1
NIL
HORIZONTAL

SLIDER
4
247
206
280
bacteria-concentration%
bacteria-concentration%
0
100
45.0
1
1
NIL
HORIZONTAL

SLIDER
4
283
206
316
bacteria-t1-percentage%
bacteria-t1-percentage%
0
100
15.0
1
1
NIL
HORIZONTAL

SLIDER
4
319
206
352
bacteria-t2-percentage%
bacteria-t2-percentage%
0
100 - bacteria-t1-percentage%
15.0
1
1
NIL
HORIZONTAL

SLIDER
4
355
206
388
bacteria-t3-percentage%
bacteria-t3-percentage%
0
100 - bacteria-t1-percentage% - bacteria-t2-percentage%
15.0
1
1
NIL
HORIZONTAL

MONITOR
217
247
399
292
# total bacteria (dead & living)
bacteria-total
17
1
11

MONITOR
310
295
399
340
# dead bacteria
dead-bacteria
17
1
11

MONITOR
217
126
356
171
# deactivated antibacteria
count antibacterias with [isActive = false]
17
1
11

MONITOR
217
295
307
340
# living bacteria
count bacterias1 + (count bacterias2) + (count bacterias3)
17
1
11

MONITOR
217
78
356
123
# living antibacteria
count antibacterias with [isActive = true]
17
1
11

PLOT
1128
10
1444
286
Bacteria population
time
pop.
0.0
100.0
0.0
2000.0
true
true
"" ""
PENS
"bacterias1" 1.0 0 -14070903 true "" "plot count bacterias1"
"bacterias2" 1.0 0 -1184463 true "" "plot count bacterias2"
"bacterias3" 1.0 0 -2674135 true "" "plot count bacterias3"

BUTTON
17
775
190
814
Reset Sliders
reset-sliders
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
1450
10
1724
159
Deactivated antibacteria
time
pop.
0.0
100.0
0.0
10.0
true
true
"" ""
PENS
"antibacterias" 1.0 0 -11085214 true "" "plot count antibacterias with [isActive = false]"

PLOT
1129
300
1444
450
Bacteria type 1 antibacteria immunity
time
amount
0.0
100.0
0.0
10.0
true
true
"" ""
PENS
"bacterias1" 1.0 0 -14070903 true "" "plot count bacterias1 with [base-resistance >= 100]"

SLIDER
4
417
206
450
bacteria-t1-reproduction-rate
bacteria-t1-reproduction-rate
0
100
50.0
1
1
%
HORIZONTAL

SLIDER
4
453
206
486
bacteria-t2-reproduction-rate
bacteria-t2-reproduction-rate
0
100
50.0
1
1
%
HORIZONTAL

SLIDER
4
489
206
522
bacteria-t3-reproduction-rate
bacteria-t3-reproduction-rate
0
100
50.0
1
1
%
HORIZONTAL

MONITOR
217
399
287
444
# bacteria 1
count bacterias1
17
1
11

MONITOR
217
447
287
492
# bacteria 2
count bacterias2
17
1
11

MONITOR
217
495
287
540
# bacteria 3
count bacterias3
17
1
11

TEXTBOX
46
229
176
259
Bacteria concentration
12
0.0
1

TEXTBOX
34
60
190
90
Antibacteria concentration
12
0.0
1

TEXTBOX
45
399
195
417
Bacteria reproduction
12
0.0
1

TEXTBOX
265
61
322
79
Counters
12
0.0
1

SLIDER
4
551
206
584
membrane-resistance-stat-growth
membrane-resistance-stat-growth
0
5
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
4
587
206
620
detectability-stat-growth
detectability-stat-growth
0
5
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
4
623
206
656
enzyme-production-stat-growth
enzyme-production-stat-growth
0
5
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
4
659
206
692
base-resistance-stat-growth
base-resistance-stat-growth
0
5
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
4
695
206
728
evolution-chance
evolution-chance
0
100
50.0
1
1
%
HORIZONTAL

SLIDER
4
731
206
764
regression-chance
regression-chance
0
100
50.0
1
1
%
HORIZONTAL

TEXTBOX
67
531
217
549
Bacteria traits
12
0.0
1

MONITOR
419
717
530
762
# bacteria on zone 1
count (bacterias1-on patches with [ pcolor = no-dosage-color ]) +\ncount (bacterias2-on patches with [ pcolor = no-dosage-color ]) +\ncount (bacterias3-on patches with [ pcolor = no-dosage-color ])
17
1
11

MONITOR
556
720
667
765
# bacteria on zone 2
count (bacterias1-on patches with [ pcolor = low-dosage-color ]) +\ncount (bacterias2-on patches with [ pcolor = low-dosage-color ]) +\ncount (bacterias3-on patches with [ pcolor = low-dosage-color ])
17
1
11

MONITOR
697
722
808
767
# bacteria on zone 3
count (bacterias1-on patches with [ pcolor = medium-dosage-color ]) +\ncount (bacterias2-on patches with [ pcolor = medium-dosage-color ]) +\ncount (bacterias3-on patches with [ pcolor = medium-dosage-color ])
17
1
11

MONITOR
841
719
952
764
# bacteria on zone 4
count (bacterias1-on patches with [ pcolor = high-dosage-color ]) +\ncount (bacterias2-on patches with [ pcolor = high-dosage-color ]) +\ncount (bacterias3-on patches with [ pcolor = high-dosage-color ])
17
1
11

MONITOR
985
721
1099
766
# bacteria on zone 5 
count (bacterias1-on patches with [ pcolor = highest-dosage-color ]) +\ncount (bacterias2-on patches with [ pcolor = highest-dosage-color ]) +\ncount (bacterias3-on patches with [ pcolor = highest-dosage-color ])
17
1
11

PLOT
1129
459
1413
643
Bacteria 2 undetectable count
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"bacterias2" 1.0 0 -1184463 true "" "plot count bacterias2 with [detectability >= 100]"

PLOT
1130
650
1469
800
Bacteria 3 enzyme production effective
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"bacterias3" 1.0 0 -2674135 true "" "plot count bacterias3 with [enzyme-production >= 100]"

PLOT
1450
171
1731
322
Time to reach highest zone
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"bacterias1" 1.0 0 -13345367 true "" "plot count bacterias1-on patches with [zone = \"HIGHEST\"] "
"bacterias2" 1.0 0 -987046 true "" "plot count bacterias2-on patches with [zone = \"HIGHEST\"] "
"bacterias3" 1.0 0 -2674135 true "" "plot count bacterias3-on patches with [zone = \"HIGHEST\"] "

SWITCH
225
731
387
764
move-antibacteria
move-antibacteria
1
1
-1000

TEXTBOX
225
678
406
738
Turning movement off reduces lag, however it makes the model a less accurate representation.
12
0.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

antibacteria
true
0
Circle -7500403 true true 17 150 53
Circle -7500403 true true 180 61 58
Polygon -7500403 true true 36 151 67 136 86 132 96 135 111 136 124 137 137 135 145 126 152 114 162 98 190 71 222 114 195 135 183 157 176 168 170 172 164 176 155 177 147 182 134 183 125 183 119 179 109 179 98 181 89 183
Polygon -7500403 true true 126 184 88 181 76 181 62 187
Polygon -7500403 true true 131 181 56 189 56 174 133 166

antibacteria-v2
true
0
Polygon -7500403 true true 128 263 124 263 118 261 112 255 107 242 107 232 109 224 115 209 120 196 124 180 129 164 131 147 129 131 120 122 109 111 99 98 97 86 96 68 100 49 107 36 124 33 139 34 156 41 169 53 171 69 176 82 184 93 190 106 194 119 197 138 196 157 193 175 184 195 175 214 172 224 173 239 177 250 174 258 164 268 152 272 128 272 112 264 107 257 107 235 108 223 110 222 108 248 110 221 172 235
Polygon -7500403 true true 170 236 141 270 114 260 107 240 110 221 152 188
Circle -7500403 true true 105 205 66

antibody
true
0
Polygon -7500403 true true 136 253 137 90 92 43 82 43 79 50 81 56 123 98 123 249 127 255 134 255
Polygon -7500403 true true 164 90 167 253 172 255 180 254 181 249 180 92 222 62 223 56 220 52 213 52 211 52
Polygon -7500403 true true 136 124 168 124 171 132 164 138 138 138 130 142 134 154 170 155 170 161 168 163 138 162 130 162
Polygon -7500403 true true 115 89 107 101 73 68 63 71 72 81 106 111 113 116 119 110 113 104 111 102
Polygon -7500403 true true 188 82 196 93 189 98 189 103 197 107 237 78 234 70 221 75 202 90
Polygon -7500403 true true 204 93 194 76 189 82
Polygon -7500403 true true 121 89 108 106 102 99 118 84

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

bacteria
true
0
Circle -7500403 true true 73 75 152
Polygon -7500403 true true 65 133 23 99 74 116 84 101 58 50 103 80 117 87 118 20 132 78 155 73 178 5 178 80 180 104 215 58 207 91 219 99 256 77 222 114 227 125 234 127 284 109 232 141 232 164 262 184 231 183 214 185 206 203 232 270 198 228 178 224 165 239 170 280 149 238 132 232 119 241 90 269 108 230 105 212 74 213 40 234 88 187 65 192 53 200 30 216 84 167 33 166 62 159 13 135 82 143

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Bacteria Evolution Experiment 1" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="bacteria-t2-percentage%">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bacteria-t3-percentage%">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bacteria-concentration%">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bacteria-t1-percentage%">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="medium-concentration%">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="highest-concentration%">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="high-concentration%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="low-concentration%">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Bacteria Evolution Experiment Version 2 (All Values)" repetitions="2" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>repeat</go>
    <metric>count turtles</metric>
    <metric>count bacterias1</metric>
    <metric>count bacterias2</metric>
    <metric>count bacterias3</metric>
    <metric>count antibacterias</metric>
    <steppedValueSet variable="bacteria-t2-percentage%" first="0" step="5" last="100"/>
    <steppedValueSet variable="detectability-stat-growth" first="0" step="0.1" last="5"/>
    <steppedValueSet variable="evolution-chance" first="0" step="5" last="100"/>
    <steppedValueSet variable="regression-chance" first="0" step="5" last="100"/>
    <steppedValueSet variable="membrane-resistance-stat-growth" first="0" step="0.1" last="5"/>
    <steppedValueSet variable="enzyme-production-stat-growth" first="0" step="0.1" last="5"/>
    <steppedValueSet variable="base-resistance-stat-growth" first="1" step="0.5" last="5"/>
    <steppedValueSet variable="highest-concentration%" first="5" step="5" last="100"/>
    <steppedValueSet variable="bacteria-t2-reproduction-rate" first="0" step="5" last="100"/>
    <steppedValueSet variable="bacteria-t3-percentage%" first="0" step="5" last="100"/>
    <steppedValueSet variable="bacteria-concentration%" first="5" step="5" last="100"/>
    <steppedValueSet variable="bacteria-t3-reproduction-rate" first="0" step="5" last="100"/>
    <steppedValueSet variable="bacteria-t1-percentage%" first="0" step="5" last="100"/>
    <steppedValueSet variable="bacteria-t1-reproduction-rate" first="0" step="5" last="100"/>
    <steppedValueSet variable="medium-concentration%" first="5" step="5" last="50"/>
    <steppedValueSet variable="high-concentration%" first="5" step="5" last="75"/>
    <steppedValueSet variable="low-concentration%" first="5" step="5" last="25"/>
  </experiment>
  <experiment name="Bacteria Evolution - Time till bacteria reaches zone 3" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>zone-reached</exitCondition>
    <metric>count turtles</metric>
    <metric>ticks</metric>
    <enumeratedValueSet variable="detectability-stat-growth">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bacteria-t2-percentage%">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evolution-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regression-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="membrane-resistance-stat-growth">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enzyme-production-stat-growth">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-resistance-stat-growth">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bacteria-t2-reproduction-rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="highest-concentration%">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bacteria-t3-percentage%">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bacteria-concentration%">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bacteria-t3-reproduction-rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bacteria-t1-percentage%">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bacteria-t1-reproduction-rate">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="medium-concentration%">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="high-concentration%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="low-concentration%">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Time for bacteria 1 to reach immunity" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>reached-immunity</exitCondition>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="detectability-stat-growth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bacteria-t2-percentage%">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evolution-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regression-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <steppedValueSet variable="membrane-resistance-stat-growth" first="0.1" step="0.1" last="5"/>
    <enumeratedValueSet variable="enzyme-production-stat-growth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-resistance-stat-growth">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="highest-concentration%">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bacteria-t2-reproduction-rate">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bacteria-t3-percentage%">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="bacteria-concentration%" first="10" step="10" last="50"/>
    <enumeratedValueSet variable="bacteria-t3-reproduction-rate">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bacteria-t1-percentage%">
      <value value="100"/>
    </enumeratedValueSet>
    <steppedValueSet variable="bacteria-t1-reproduction-rate" first="50" step="50" last="100"/>
    <enumeratedValueSet variable="medium-concentration%">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="high-concentration%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="low-concentration%">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Time for bacteria 2 to reach undetectability" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <steppedValueSet variable="detectability-stat-growth" first="0.1" step="0.1" last="5"/>
    <enumeratedValueSet variable="bacteria-t2-percentage%">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evolution-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regression-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="membrane-resistance-stat-growth">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enzyme-production-stat-growth">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-resistance-stat-growth">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="highest-concentration%">
      <value value="75"/>
    </enumeratedValueSet>
    <steppedValueSet variable="bacteria-t2-reproduction-rate" first="50" step="50" last="100"/>
    <enumeratedValueSet variable="bacteria-t3-percentage%">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="bacteria-concentration%" first="10" step="10" last="50"/>
    <enumeratedValueSet variable="bacteria-t3-reproduction-rate">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bacteria-t1-percentage%">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bacteria-t1-reproduction-rate">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="medium-concentration%">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="high-concentration%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="low-concentration%">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Time for bacteria 3 to reach 100% deactivation chance" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="detectability-stat-growth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bacteria-t2-percentage%">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evolution-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regression-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="membrane-resistance-stat-growth">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="enzyme-production-stat-growth" first="0.1" step="0.1" last="5"/>
    <enumeratedValueSet variable="base-resistance-stat-growth">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="highest-concentration%">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bacteria-t2-reproduction-rate">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bacteria-t3-percentage%">
      <value value="100"/>
    </enumeratedValueSet>
    <steppedValueSet variable="bacteria-concentration%" first="10" step="10" last="50"/>
    <steppedValueSet variable="bacteria-t3-reproduction-rate" first="50" step="50" last="100"/>
    <enumeratedValueSet variable="bacteria-t1-percentage%">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bacteria-t1-reproduction-rate">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="medium-concentration%">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="high-concentration%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="low-concentration%">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Time to reach final zone" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>reached-zone-highest1</exitCondition>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="bacteria-t2-percentage%">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="detectability-stat-growth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="evolution-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="regression-chance">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="membrane-resistance-stat-growth">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="enzyme-production-stat-growth">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="base-resistance-stat-growth">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="highest-concentration%">
      <value value="75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bacteria-t2-reproduction-rate">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bacteria-t3-percentage%">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bacteria-concentration%">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bacteria-t3-reproduction-rate">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bacteria-t1-percentage%">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="bacteria-t1-reproduction-rate">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="medium-concentration%">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="high-concentration%">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="low-concentration%">
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
