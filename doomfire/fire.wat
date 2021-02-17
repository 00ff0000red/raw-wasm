;; FIRE_WIDTH = 320
;; FIRE_HEIGHT = 168
;; FIRE_WIDTH * FIRE_HEIGHT = 53760
;; FIRE_WIDTH * (FIRE_HEIGHT - 1) = 53440

(import "0" "random" (func $globalThis::Math::random (result f64)))
(import "1" "requestAnimationFrame" (func $globalThis::requestAnimationFrame (param funcref)))
(import "2" "0" (func $local::putImageData))
(import "2" "1" (memory 5 5))

;; 5 pages * 64KiB bytes per page:
;; [0, 53760)       => firePixels, 1 byte per pixel.
;; [53760, 268800)  => canvasData, 4 bytes per pixel.
;; [268800, 268948) => Palette data, RGBA.

;; Palette data.
(data (i32.const 268800)
  "\07\07\07\FF\1F\07\07\FF\2F\0F\07\FF\47\0F\07\FF\57\17\07\FF\67\1F\07\FF"
  "\77\1F\07\FF\8F\27\07\FF\9F\2F\07\FF\AF\3F\07\FF\BF\47\07\FF\C7\47\07\FF"
  "\DF\4F\07\FF\DF\57\07\FF\DF\57\07\FF\D7\5F\07\FF\D7\5F\07\FF\D7\67\0F\FF"
  "\CF\6F\0F\FF\CF\77\0F\FF\CF\7F\0F\FF\CF\87\17\FF\C7\87\17\FF\C7\8F\17\FF"
  "\C7\97\1F\FF\BF\9F\1F\FF\BF\9F\1F\FF\BF\A7\27\FF\BF\A7\27\FF\BF\AF\2F\FF"
  "\B7\AF\2F\FF\B7\B7\2F\FF\B7\B7\37\FF\CF\CF\6F\FF\DF\DF\9F\FF\EF\EF\C7\FF"
  "\FF\FF\FF\FF")

;; Run setup at start.
(start $setup)

;; for the $run recursion
(elem func $run)

(func $setup
	;; Fill bottom row with color 36, (R=0xFF, G=0xFF, B=0xFF).

	i32.const 53439
	i32.const 36
	i32.const 320
	memory.fill

	ref.func $run
	return_call $globalThis::requestAnimationFrame
)

(func $run (export "run")
	(local $i i32)
	(local $pixel i32)
	(local $randIdx i32)

	;; Update the fire.
	loop $xloop
		loop $yloop
			;; if (pixel = memory[i += 320]) != 0
			local.get $i
			i32.const 320
			i32.add
			local.tee $i
			i32.load8_u
			local.tee $pixel
			if (result i32 i32)
				local.get $i ;; leave on stack until $randIdx is reassigned

				;; randIdx = round(random() * 3.0) & 3
				call $globalThis::Math::random
				f64.const 3.0
				f64.mul
				f64.nearest
				i32.trunc_f64_u
				i32.const 3
				i32.and
				local.tee $randIdx

				;; memory[i - (randIdx = round(random() * 3.0) & 3) - 319] = pixel - (randIdx & 1)
				i32.sub
				i32.const 319
				i32.sub

				local.get $pixel
				local.get $randIdx
				i32.const 1
				i32.and
				i32.sub
			else
				;; memory[i - 320] = 0
				local.get $i
				i32.const 320
				i32.sub
				i32.const 0
			end ;; end if
			i32.store8 ;; offset=-320?

			;; loop if i < 53760 - 320
			local.get $i
			i32.const 53440
			i32.lt_u
			br_if $yloop
		end

		;; i -= 53760 - 320 - 1
		local.get $i
		i32.const 53439
		i32.sub
		local.tee $i ;; loop if i != 320
		i32.const 320
		i32.ne
		br_if $xloop
	end

	;; copy from firePixels to canvasData, using palette data.
	i32.const 53760
	local.set $i
	loop
		local.get $i
		i32.const 1
		i32.sub
		local.tee $i

		;; memory[53760 + (--i << 2)] = memory[268800 + (memory[i] << 2)]
		i32.const 2
		i32.shl
		local.get $i
		i32.load8_u
		i32.const 2
		i32.shl

		i32.load offset=268800
		i32.store offset=53760

		;; loop if i != 0
		local.get $i
		br_if 0
	end
	(;
		i32.const 53760
		i32.const 268800
		i32.const 53759 ;; (53760 - 1)
		memory.copy
	;)

	call $local::putImageData

	ref.func $run
	return_call $globalThis::requestAnimationFrame
)
