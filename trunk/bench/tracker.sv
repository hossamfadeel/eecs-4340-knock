class tracker;
  real total = 0, failed = 0;
  real count[string];

  function new();
    total = 0;
    failed = 0;
  endfunction
  
  function perform(string action, string displayText);
    count[action] = count[action] +`INTERFACES;

    $display("%0d: %s", $time, displayText);
  endfunction

  function pass();
    total++;
  endfunction

  function fail(string failure);
    total++;
    failed++;

    $display(failure);
  endfunction

  function done();
    $display("\n\n======================================================");
    $display("actions:\t%d", total);
    $display("failures:\t%d\t\t%1.2f%%", failed, 100*failed/total);
    $display("------------------------------------------------------");
    foreach(count[s]) begin
      $display("%s:\t\t%d\t\t%1.2f%%", s, count[s], 100*count[s]/total);
    end  
    $display("======================================================\n\n");
  endfunction
endclass
