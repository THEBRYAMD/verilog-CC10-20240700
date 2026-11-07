
`timescale 1ns/1ps

module tb_student;

    // Generador de reloj
    reg clk = 0;
    always #5 clk = ~clk;

    // Entradas de nuestro circuito
    reg rst = 0;
    reg en = 1;
    reg [7:0] cmd = 0;
    reg [7:0] data = 0;

    // Salidas de los dos circuitos
    wire [15:0] y3;
    wire [15:0] y5;

    integer errores = 0;

    // Primer circuito: K = 3
    top_module #(.K(3)) dut3 (
        .clk(clk),
        .rst(rst),
        .en(en),
        .cmd(cmd),
        .data(data),
        .y(y3)
    );

    // Segundo circuito: K = 5
    top_module #(.K(5)) dut5 (
        .clk(clk),
        .rst(rst),
        .en(en),
        .cmd(cmd),
        .data(data),
        .y(y5)
    );

    // Comprobar las salidas
    task comprobar;
        input [15:0] esperado3;
        input [15:0] esperado5;
        begin
            if (y3 !== esperado3) begin
                $display("ERROR K=3: y=%h, esperado=%h",
                         y3, esperado3);
                errores = errores + 1;
            end

            if (y5 !== esperado5) begin
                $display("ERROR K=5: y=%h, esperado=%h",
                         y5, esperado5);
                errores = errores + 1;
            end
        end
    endtask

    // Ejecutar un ciclo y comprobar resultados
    task paso;
        input r;
        input e;
        input boton;
        input [15:0] esperado3;
        input [15:0] esperado5;
        begin
            @(negedge clk);
            rst = r;
            en = e;
            cmd = {7'b0, boton};

            @(posedge clk);
            #1;
            comprobar(esperado3, esperado5);
        end
    endtask

    initial begin

        // Reiniciar los circuitos
        paso(1, 1, 0, 16'h0000, 16'h0000);

        // Pulsacion de dos ciclos
        paso(0, 1, 1, 16'h0000, 16'h0000);
        paso(0, 1, 1, 16'h0000, 16'h0000);

        // Liberar boton: duracion = 2
        paso(0, 1, 0, 16'h0102, 16'h0102);

        // Valid vuelve a cero
        paso(0, 1, 0, 16'h0002, 16'h0002);

        // Pulsacion de tres ciclos
        paso(0, 1, 1, 16'h0002, 16'h0002);
        paso(0, 1, 1, 16'h0002, 16'h0002);
        paso(0, 1, 1, 16'h0002, 16'h0002);

        // Para K=3 es larga, para K=5 es corta
        paso(0, 1, 0, 16'h0303, 16'h0103);

        // Resultado final
        if (errores == 0)
            $display("OK: pruebas iniciales superadas");
        else
            $fatal(1, "Fallaron %0d comprobaciones", errores);

        $finish;
    end

endmodule
