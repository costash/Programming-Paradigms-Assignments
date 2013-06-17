; Tema 3 PP
; Constantin Șerban-Rădoi 323CA
; Mai 2012

; O stare a unei mutări
(deftemplate path
	(multislot minge)	; Pozitia curenta a mingii
	(multislot mutari)	; Traseul urmat de la start
	(slot is_jumping)	; 1 dacă e în curs de săritură, 0 altfel
	(multislot poz_curenta)	; x, y poziția curentă
	(multislot dir_curenta)	; x, y direcția curentă
	(multislot next_poz)	; x, y poziția viitoare
	(multislot dir)		; Lista curentă de direcții
	(slot id)			; Id lume
	)

; Retract world facts
(defrule clear-world
	(declare (salience -100))
	?f <- (world (id $?))
	=>
	(retract ?f)
	)

; Retract path
(defrule clear-path
	(declare (salience -100))
	?traseu <- (path (id ?))
	=>
	(retract ?traseu)
	)

; Initializare path-ului
(defrule init-pos
	(declare (salience 15))
	?lumea <- (world (ball ?blin ?bcol)
					(id ?lume)
					(moves $?mvs))
	(not (world (id ?lume)
				(moves $? ?blin ?bcol -)))
	=>
	(assert (path (mutari ?blin ?bcol - $?mvs)
				(minge ?blin ?bcol)
				(id ?lume)
				(is_jumping 0)
				(dir_curenta 0 0)
				(poz_curenta ?blin ?bcol)))
	(modify ?lumea (moves ?blin ?bcol -))
	)

; Ia direcțiile posibile din poziția curentă
; Sare de pe x y către toate direcțiile unde are oameni adiacenți
; ținând cont că sub minge nu se află nimic
(defrule get-dirs
	(declare (salience 14))
	?lumea <- (world (id ?lume) (moves $?mvs)
				(men $?fst ?mlin ?mcol - $?last)
				(limit ?nlin ?ncol))
	?traseu <- (path (id ?lume)
					(minge ?balllin ?ballcol)
					(poz_curenta ?curlin ?curcol)
					(mutari $?primele ?lastlin ?lastcol -)
					(dir_curenta ?dcx ?dcy)
					(dir $?dirs))
	; Nu am mai băgat deja omul în path
	(not (path (id ?lume )
				(dir $? ?mlin ?mcol - $?)
				(poz_curenta ?curlin ?curcol)
				(dir_curenta ?dcx ?dcy)))
	; Omul este adiacent cu mine sau mă aflu pe el
	(test (and
			(<= (abs (- ?mlin ?curlin)) 1)
			(<= (abs (- ?mcol ?curcol)) 1)
			(not (and (= (- ?mlin ?curlin) 0)
					(= (- ?mcol ?curcol) 0)))
			))
	; Mențin traiectoria curentă
	(test (or
			(and
				(= ?dcx 0)
				(= ?dcy 0))
			(and
				(= (- ?mlin ?curlin) ?dcx)
				(= (- ?mcol ?curcol) ?dcy))
			))
	=>
	(assert (path (id ?lume)
				(minge ?balllin ?ballcol)
				(mutari $?primele ?lastlin ?lastcol -)
				(is_jumping 1)
				(dir_curenta (- ?mlin ?curlin) (- ?mcol ?curcol))
				(dir $?dirs ?mlin ?mcol -)
				(poz_curenta ?mlin ?mcol)
				(next_poz (+ ?mlin (- ?mlin ?curlin)) 
						(+ ?mcol (- ?mcol ?curcol)))))
	)

; Face săritura
; Pozitia curenta se afla deasupra unui om
(defrule compute-jump
	(declare (salience 13))
	?lumea <- (world (id ?lume)
					
					(men $?fst ?mlin ?mcol - $?last)
					(limit ?nlin ?ncol))
	?traseu <- (path (id ?lume)
					(minge ?balllin ?ballcol)
					(dir_curenta ?curdirlin ?curdircol)
					(dir $?dirs )
					(mutari $?primele ?lastlin ?lastcol -)
					(poz_curenta ?curlin ?curcol)
					(next_poz ?nextlin ?nextcol)
					(is_jumping 1))
	; Sau nu am om pe poziția următoare, sau am un path ca mai sus
	(or (not (world (id ?lume)
				(men $? ?nextlin ?nextcol $?)))
		(path (id ?lume)
			(minge ?balllin ?ballcol)
			(dir_curenta ?curdirlin ?curdircol)
			(dir $? ?nextlin ?nextcol $? )
			(mutari $?primele ?lastlin ?lastcol -)
			(poz_curenta ?curlin ?curcol)
			(next_poz ?nextlin ?nextcol)
			(is_jumping 1)))
	=>
	(assert (path (minge ?nextlin ?nextcol)
				(id ?lume)
				(mutari $?primele ?lastlin ?lastcol - ?nextlin ?nextcol -)
				(is_jumping 0)
				(next_poz)
				(poz_curenta ?nextlin ?nextcol)
				(dir $?dirs)
				(dir_curenta 0 0)))
	)

; Am găsit o soluție, deci assert-ui WIN
(defrule solutie
	(declare (salience 41))
	(world (limit ?nlin ?ncol) 
			(ball $?) 
			(men $?) 
			(id ?lume) 
			(moves $?mvs))

	(path (id ?lume)
			(mutari $?mut)
			(minge ?blin ?bcol))
	(test (= ?blin (- ?nlin 1)))
	=>
	(assert (win (id ?lume) 
				(moves $?mut)))
	)

; Dacă am câștigat mă opresc
(defrule cleanup-win-path
	(declare (salience 42))
	(win (id ?id))
	?p <- (path (id ?id))
	=>
	(retract ?p))

; Same
(defrule cleanup-win-world
	(declare (salience 42))
	(win (id ?id))
	?w <- (world (id ?id))
	=>
	(retract ?w))
