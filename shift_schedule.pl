:- use_module(library(clpfd)).
:- use_module(library(lists)).
:- use_module(library(between)).

% from https://www.swi-prolog.org/pldoc/doc/_SWI_/library/lists.pl?show=src#flatten/2
flatten(List, FlatList) :-
    flatten(List, [], FlatList0),
    !,
    FlatList = FlatList0.

flatten(Var, Tl, [Var|Tl]) :-
    var(Var),
    !.
flatten([], Tl, Tl) :- !.
flatten([Hd|Tl], Tail, List) :-
    !,
    flatten(Hd, FlatHeadTail, List),
    flatten(Tl, Tail, FlatHeadTail).
flatten(NonList, Tl, [NonList|Tl]).


% availability_constraint_schedule
availability_constraint_shift(_, []).
availability_constraint_shift(EmployeeId, [Slot|Rest]) :-
    Slot #\= EmployeeId,
    availability_constraint_shift(EmployeeId, Rest).

% availability_constraint_schedule(+Availability, +Shifts, +EmployeeId)
availability_constraint_schedule([], [], _) :- !.
availability_constraint_schedule([Availability|TA], [Slots|TS], EmployeeId) :- 
    (
        Availability = 0,
        % maplist(availability_constraint_shift(EmployeeId), Slots)
        availability_constraint_shift(EmployeeId, Slots);
        % Slots #\= EmployeeId;
        Availability = 1
    ),
    availability_constraint_schedule(TA, TS, EmployeeId).

employees_availability([], _, _).
employees_availability([Availability-_|Rest], Slots, N) :-
    availability_constraint_schedule(Availability, Slots, N),
    NInc is N + 1,
    employees_availability(Rest, Slots, NInc).


% job_constraint_schedule(+Availability, +Shifts, +EmployeeId)
job_constraint_schedule(_, _, [], []) :- !.
job_constraint_schedule(PossibleJobs, EmployeeId, [Slot|TS], [Job|JS]) :- 
    (member(Job, PossibleJobs); Slot #\=EmployeeId),
    !, % red cut, if member then do nothing else add constraint
    job_constraint_schedule(PossibleJobs, EmployeeId, TS, JS).


employees_jobs([], _, _, _).
employees_jobs([_-PossibleJobs|Rest], FlatSlots, FlatJobs, N) :-
    job_constraint_schedule(PossibleJobs, N, FlatSlots, FlatJobs),
    NInc is N + 1,
    employees_jobs(Rest, FlatSlots, FlatJobs, NInc).

% http://www.pathwayslms.com/swipltuts/clpfd/clpfd.html
% https://sicstus.sics.se/sicstus/docs/4.3.2/html/sicstus/

shift_slots_inner(Shift, Jobs, Slots) :-
    length(Jobs, EmployeesPerShift),
    length(Slots, EmployeesPerShift),
    keys_and_values(Shift, Jobs, Slots), !.

shift_slots(Shifts, Jobs, Slots) :-
    maplist(shift_slots_inner, Shifts, Jobs, Slots), !.

no_successive_shifts([Slots1]) :- all_different(Slots1).
no_successive_shifts([Slots1, Slots2|Rest]) :-
    append(Slots1, Slots2, BothSlots),
    all_different(BothSlots),
    no_successive_shifts([Slots2|Rest]).

schedule(Shifts, Options) :-
    length(Shifts, NumberOfShifts),
    (member(minShifts(MinShifts), Options) -> true; MinShifts = 0),
    (member(minShifts(MaxShifts), Options) -> true; MaxShifts = NumberOfShifts),
    % length(Shifts, 7),
    Shifts = [
        [D11-manager, D12-bartender], 
        [D21-manager, D22-bartender, D23-bartender],
        [D31-manager, D32-bartender], 
        [D41-manager, D42-bartender, D43-bartender],
        [D51-manager, D52-bartender, D53-bartender, D54-bartender],
        [D61-manager, D62-bartender, D63-bartender, D64-bartender],
        [D71-manager, D72-bartender, D73-bartender]
        ],
    shift_slots(Shifts, Slots, Jobs),
    Employees = [
        [1, 0, 1, 0, 1, 1, 0]-[bartender],
        [1, 1, 1, 1, 1, 1, 0]-[bartender],
        [1, 1, 1, 1, 1, 1, 1]-[bartender],
        [1, 1, 1, 1, 1, 1, 1]-[bartender],
        [1, 1, 1, 1, 1, 0, 1]-[manager],
        [1, 1, 1, 1, 1, 1, 0]-[manager, bartender],
        [1, 1, 1, 1, 1, 1, 1]-[manager, bartender],
        [1, 0, 1, 1, 1, 1, 1]-[bartender]
        ],
    length(Employees, NumberOfEmployees),
    length(ShiftCardinality, NumberOfEmployees),
    bagof(X, between(1, NumberOfEmployees, X), EmployeeIds), % EmployeeIds = [1, 2, 3, ..., NumberOfEmployees]
    flatten(Slots, FlatSlots),
    flatten(Jobs, FlatJobs),
    domain(FlatSlots, 1, NumberOfEmployees), % initially set domain to all possible employees
    domain(ShiftCardinality, MinShifts, MaxShifts),

    % edit the domains for availability
    employees_availability(Employees, Slots, 1),
    % edit the domains for job competence
    employees_jobs(Employees, FlatSlots, FlatJobs, 1),

    (
        member(forbidSuccessiveShifts, Options) -> no_successive_shifts(Slots);
        maplist(all_different, Slots)
    ),

    % limit the number of shifts per schedule for each employee
    keys_and_values(Counts, EmployeeIds, ShiftCardinality),
    global_cardinality(FlatSlots, Counts, []),

    labeling([], FlatSlots).
