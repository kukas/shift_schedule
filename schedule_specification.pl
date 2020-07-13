shifts([
    [_-manager, _-bartender], 
    [_-manager, _-bartender, _-bartender],
    [_-manager, _-bartender], 
    [_-manager, _-bartender, _-bartender],
    [_-manager, _-bartender, _-bartender, _-bartender],
    [_-manager, _-bartender, _-bartender, _-bartender],
    [_-manager, _-bartender, _-bartender]
]).
employees([
    [1, 0, 1, 0, 1, 1, 0]-[bartender],
    [1, 1, 1, 1, 1, 1, 0]-[bartender],
    [0, 1, 1, 1, 1, 1, 0]-[bartender],
    [1, 0, 1, 0, 1, 1, 1]-[bartender],
    [1, 1, 1, 1, 1, 0, 1]-[manager],
    [1, 1, 0, 1, 0, 1, 0]-[manager, bartender],
    [1, 0, 1, 0, 1, 0, 1]-[manager, bartender],
    [1, 0, 1, 1, 1, 0, 1]-[bartender]
]).
