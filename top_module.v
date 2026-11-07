
module top_module #(parameter integer K = 3)(
    input wire clk,
    input wire rst,
    input wire en,
    input wire [7:0] cmd,
    input wire [7:0] data,
    output wire [15:0] y
);

    // Registro que cuenta los ciclos del boton
    reg [7:0] contador;

    // Registros de resultados
    reg [7:0] duracion;
    reg valid;
    reg long_press;

    // Distribucion de la salida de 16 bits
    assign y = {6'b000000, long_press, valid, duracion};

    // Logica secuencial
    always @(posedge clk) begin

        // RESET: prioridad maxima
        if (rst) begin
            contador   <= 8'd0;
            duracion   <= 8'd0;
            valid      <= 1'b0;
            long_press <= 1'b0;
        end

        else begin

            // Valid solo dura un ciclo de reloj
            valid <= 1'b0;

            // Solo procesar cuando esta habilitado
            if (en) begin

                // Boton presionado
                if (cmd[0]) begin

                    // Contador saturado en 255
                    if (contador < 8'd255)
                        contador <= contador + 8'd1;

                end

                // Boton liberado
                else begin

                    // Publicar solo si hubo pulsacion
                    if (contador > 8'd0) begin

                        duracion <= contador;

                        // Clasificar pulsacion
                        long_press <= (contador >= K);

                        // Avisar que hay un resultado
                        valid <= 1'b1;

                        // Preparar siguiente pulsacion
                        contador <= 8'd0;

                    end
                end
            end
        end
    end

endmodule
