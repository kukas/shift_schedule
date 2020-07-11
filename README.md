# Shift Schedule
A tool for scheduling work shifts (for example in a cafe). Programmed using Constraint Programming in SICStus Prolog. 

## Description of the problem

We would like to create a monthly schedule for part-time employees in a café. One month is divided into shifts and each shift has several slots for the employees. The number of slots per shift can be adjusted because some shifts require more workers to be present. The schedule should allocate each worker the requested number of shifts while respecting their availability for the job. Each worker also has an individual skillset (a cook cannot operate the coffee machine and vice versa). The slots can be therefore occupied only by workers with relevant skills. Lastly we would like to constrain the schedule so that no worker works two shifts in a row and possibly we would like to assign a similar number of shifts to each employee.

## Formal description

![Formal description in LaTeX](./formal_description.jpeg)

## Usage

Edit the file `schedule_specification.pl` and use the predicate `schedule/2` to compute the schedule. The schedule predicate is used like this:
``` prolog
:- schedule(-Schedule, +Options).
```
Where `Schedule` is free variable that will be unified with a computed schedule and `Options` is a list with options for the schedule computation. Possible settings for the options list are:
| Option       | Description |
| ------------ | ----------- |
| `minShifts(N)` | Set the minimum number of shifts assigned to one employee to N |
| `maxShifts(N)` | Set the maximum number of shifts assigned to one employee to N |
| `forbidSuccessiveShifts` | Create schedule with no employee having to do two shifts in a row |
| `distributeShifts` | Optimize the schedule so that the employees have similar numbers of shifts |

The `schedule_specification.pl` contains two unary relations `shifts` and `employees`. The relation `shifts` specifies slots to be assigned in each shift. Relation `employees` specifies the availability and skills of each employee. The availability list must be same length as the number of shifts, for each shift we specify whether the employee is available `1` or unavailable `0`.

## Examples

``` prolog
:- schedule(Shifts, []). % generate any schedule
:- schedule(Shifts, [forbidSuccessiveShifts]). % generate a schedule without any successive shifts for any employee
:- schedule(Shifts, [minShifts(2), maxShifts(4)]). % generate a schedule with specified minimum and maximum number of shifts for each employee
:- schedule(Shifts, [forbidSuccessiveShifts, distributeShifts]). % generate a schedule with similarly distributed number of shifts
```

## Resources used

- [Constraint Programming at MFF UK](http://ktiml.mff.cuni.cz/~bartak/podminky)
- [CLP(FD) Constraint Logic Programming over Finite Domains](http://www.pathwayslms.com/swipltuts/clpfd/clpfd.html)
- [SICStus Prolog manual ver. 4.3.2.](https://sicstus.sics.se/sicstus/docs/4.3.2/html/sicstus/)
