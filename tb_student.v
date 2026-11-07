
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


    // Variables para las pruebas pseudoaleatorias
    integer i;
    reg [31:0] semilla;

    // Modelo de referencia
    reg [7:0] ref_contador;
    reg [7:0] ref_duracion;
    reg ref_valid;
    reg ref_larga3;
    reg ref_larga5;

    // Entradas aleatorias
    reg random_rst;
    reg random_en;
    reg random_boton;
    reg [7:0] random_cmd;
    reg [7:0] random_data;

    // Resultados esperados
    reg [15:0] esperado3;
    reg [15:0] esperado5;


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
        
        // PRUEBA: valid se borra incluso con en=0
        paso(0, 0, 0, 16'h0203, 16'h0003);

        // Sin nueva pulsacion, se conserva el resultado
        paso(0, 1, 0, 16'h0203, 16'h0003);

        // PRUEBA: pausa durante una pulsacion
        paso(0, 1, 1, 16'h0203, 16'h0003);
        paso(0, 1, 1, 16'h0203, 16'h0003);

        // Deshabilitar el circuito
        paso(0, 0, 1, 16'h0203, 16'h0003);

        // Soltar el boton mientras en=0
        paso(0, 0, 0, 16'h0203, 16'h0003);

        // Volver a habilitar: publica duracion 2
        paso(0, 1, 0, 16'h0102, 16'h0102);

        // PRUEBA: reset borra todo
        paso(1, 1, 0, 16'h0000, 16'h0000);
        
        
        // =========================================
        // PRUEBA: SATURACION DEL CONTADOR
        // =========================================

        // Reiniciar antes de las pruebas
        paso(1, 1, 0, 16'h0000, 16'h0000);

        // CASO 1: Pulsacion de un solo ciclo
        paso(0, 1, 1, 16'h0000, 16'h0000);

        // Soltar: duracion = 1, pulsacion corta
        paso(0, 1, 0, 16'h0101, 16'h0101);

        // Valid debe volver a cero
        paso(0, 1, 0, 16'h0001, 16'h0001);


        // CASO 2: Pulsacion de 255 ciclos
        paso(1, 1, 0, 16'h0000, 16'h0000);

        repeat (255)
            paso(0, 1, 1, 16'h0000, 16'h0000);

        // Soltar: duracion = 255
        paso(0, 1, 0, 16'h03FF, 16'h03FF);

        // Valid vuelve a cero; resultado retenido
        paso(0, 1, 0, 16'h02FF, 16'h02FF);


        // CASO 3: Pulsacion de 260 ciclos
        paso(1, 1, 0, 16'h0000, 16'h0000);

        repeat (260)
            paso(0, 1, 1, 16'h0000, 16'h0000);

        // Aunque fueron 260, debe publicar 255
        paso(0, 1, 0, 16'h03FF, 16'h03FF);

        // Comprobar que el resultado se conserva
        paso(0, 1, 0, 16'h02FF, 16'h02FF);
        
        
        // =========================================
        // PRUEBA: FRONTERAS K-1 Y K
        // =========================================

        paso(1, 1, 0, 16'h0000, 16'h0000);

        // Pulsacion de 4 ciclos
        repeat (4)
            paso(0, 1, 1, 16'h0000, 16'h0000);

        // K=3: larga, K=5: corta
        paso(0, 1, 0, 16'h0304, 16'h0104);

        // Valid vuelve a cero
        paso(0, 1, 0, 16'h0204, 16'h0004);


        // Pulsacion de 5 ciclos
        repeat (5)
            paso(0, 1, 1, 16'h0204, 16'h0004);

        // Ambas son largas
        paso(0, 1, 0, 16'h0305, 16'h0305);


        // =========================================
        // PRUEBA: RESET DURANTE PULSACION
        // =========================================

        // Reset inicial
        paso(1, 1, 0, 16'h0000, 16'h0000);

        // Comenzar pulsacion de 4 ciclos
        repeat (4)
            paso(0, 1, 1, 16'h0000, 16'h0000);

        // Reset mientras el boton sigue presionado
        paso(1, 1, 1, 16'h0000, 16'h0000);

        // Soltar boton: no debe publicar nada
        paso(0, 1, 0, 16'h0000, 16'h0000);

        // Comprobar que todo sigue en cero
        paso(0, 1, 0, 16'h0000, 16'h0000);


        // =========================================
        // PRUEBA: PRIORIDAD DEL RESET
        // =========================================

        // Boton presionado durante 3 ciclos
        repeat (3)
            paso(0, 1, 1, 16'h0000, 16'h0000);

        // Reset activo aunque en=0
        paso(1, 0, 1, 16'h0000, 16'h0000);

        // Al habilitar y liberar, no hay resultado
        paso(0, 1, 0, 16'h0000, 16'h0000);

        
        // =========================================
        // PRUEBA: FRONTERAS K-1 Y K
        // =========================================

        // Reiniciamos los dos circuitos
        paso(1, 1, 0, 16'h0000, 16'h0000);

        // Pulsacion de 4 ciclos
        repeat (4)
            paso(0, 1, 1, 16'h0000, 16'h0000);

        // K=3: larga / K=5: corta
        paso(0, 1, 0, 16'h0304, 16'h0104);

        // Valid vuelve a cero
        paso(0, 1, 0, 16'h0204, 16'h0004);

        // Pulsacion de 5 ciclos
        repeat (5)
            paso(0, 1, 1, 16'h0204, 16'h0004);

        // Ambas pulsaciones son largas
        paso(0, 1, 0, 16'h0305, 16'h0305);

        // =========================================
        // PRUEBA: VALID CON EN=0
        // =========================================

        // Se borra valid pero se conserva el resultado
        paso(0, 0, 0, 16'h0205, 16'h0205);

        // =========================================
        // PRUEBA: RESET DURANTE PULSACION
        // =========================================

        // Iniciamos otra pulsacion de 3 ciclos
        repeat (3)
            paso(0, 1, 1, 16'h0205, 16'h0205);

        // Reset activo incluso con en=0 y boton=1
        paso(1, 0, 1, 16'h0000, 16'h0000);

        // Liberamos el boton
        // No debe publicarse ninguna pulsacion
        paso(0, 1, 0, 16'h0000, 16'h0000);

        // Comprobamos que todo sigue en cero
        paso(0, 1, 0, 16'h0000, 16'h0000);
        
        
        // =========================================
        // PRUEBA G6: 900 CICLOS PSEUDOALEATORIOS
        // =========================================

        // Reset para iniciar desde un estado conocido
        paso(1, 1, 0, 16'h0000, 16'h0000);

        // Inicializar nuestro modelo de referencia
        ref_contador = 8'd0;
        ref_duracion = 8'd0;
        ref_valid = 1'b0;
        ref_larga3 = 1'b0;
        ref_larga5 = 1'b0;

        // Semilla fija para repetir las pruebas
        semilla = 32'h1A2B3C4D;

        for (i = 0; i < 900; i = i + 1) begin

            // Generar un nuevo numero pseudoaleatorio
            semilla = semilla * 32'd1664525
                    + 32'd1013904223;

            // Preparar entradas variables
            random_rst = (semilla[31:26] == 6'b000000);
            random_en = (semilla[25:23] != 3'b000);
            random_boton = (semilla[22:21] != 2'b00);

            random_cmd = {semilla[20:14], random_boton};
            random_data = semilla[13:6];

            // MODELO DE REFERENCIA
            if (random_rst) begin

                ref_contador = 8'd0;
                ref_duracion = 8'd0;
                ref_valid = 1'b0;
                ref_larga3 = 1'b0;
                ref_larga5 = 1'b0;

            end
            else begin

                // Valid se borra en cada ciclo
                ref_valid = 1'b0;

                if (random_en) begin

                    if (random_cmd[0]) begin

                        // Contador con saturacion
                        if (ref_contador < 8'd255)
                            ref_contador = ref_contador + 8'd1;

                    end
                    else if (ref_contador > 8'd0) begin

                        // Publicar resultado al liberar
                        ref_duracion = ref_contador;

                        // Clasificar para cada K
                        ref_larga3 = (ref_contador >= 3);
                        ref_larga5 = (ref_contador >= 5);

                        ref_valid = 1'b1;
                        ref_contador = 8'd0;

                    end
                end
            end

            // Construir los resultados esperados
            esperado3 = {6'b000000, ref_larga3,
                         ref_valid, ref_duracion};

            esperado5 = {6'b000000, ref_larga5,
                         ref_valid, ref_duracion};

            // Aplicar las entradas al circuito real
            @(negedge clk);
            rst = random_rst;
            en = random_en;
            cmd = random_cmd;
            data = random_data;

            // Esperar el resultado del circuito
            @(posedge clk);
            #1;

            // Mostrar el ciclo si existe una diferencia
            if ((y3 !== esperado3) ||
                (y5 !== esperado5)) begin

                $display("FALLO en ciclo aleatorio %0d", i);
                $display("rst=%b en=%b cmd=%h data=%h",
                         rst, en, cmd, data);
            end

            // Reutilizar nuestra tarea de comprobacion
            comprobar(esperado3, esperado5);

        end

        if (errores == 0)
            $display("OK: 900 ciclos aleatorios superados");


        // Resultado final
        if (errores == 0)
            $display("OK: pruebas iniciales superadas");
        else
            $fatal(1, "Fallaron %0d comprobaciones", errores);

        $finish;
    end

endmodule
