;; Constants
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-UNAUTHORIZED (err u401))
(define-constant ERR-INVALID-RATING (err u400))
(define-constant MAX-RATING u5)

;; Data variables
(define-data-var session-counter uint u0)

;; Data maps
(define-map sessions uint {
    name: (string-ascii 50),
    description: (string-ascii 500),
    host: principal,
    timestamp: uint,
    participants: (list 50 principal),
    status: (string-ascii 20)
})

(define-map recipes uint {
    session-id: uint,
    name: (string-ascii 100),
    content: (string-ascii 1000),
    author: principal
})

(define-map user-points principal uint)
(define-map session-ratings {session-id: uint, user: principal} uint)

;; Public functions
(define-public (create-session (name (string-ascii 50)) (description (string-ascii 500)) (timestamp uint))
    (let ((session-id (+ (var-get session-counter) u1)))
        (map-set sessions session-id {
            name: name,
            description: description,
            host: tx-sender,
            timestamp: timestamp,
            participants: (list tx-sender),
            status: "active"
        })
        (var-set session-counter session-id)
        (add-points tx-sender u10)
        (ok session-id)
    )
)

(define-public (join-session (session-id uint))
    (let ((session (unwrap! (map-get? sessions session-id) ERR-NOT-FOUND)))
        (if (is-eq (len (get participants session)) u50)
            (err u429)
            (let ((new-participants (append (get participants session) tx-sender)))
                (map-set sessions session-id (merge session {participants: new-participants}))
                (add-points tx-sender u5)
                (ok true)
            )
        )
    )
)

(define-public (share-recipe (session-id uint) (name (string-ascii 100)) (content (string-ascii 1000)))
    (let ((session (unwrap! (map-get? sessions session-id) ERR-NOT-FOUND)))
        (asserts! (is-participant session-id tx-sender) ERR-UNAUTHORIZED)
        (map-set recipes session-id {
            session-id: session-id,
            name: name,
            content: content,
            author: tx-sender
        })
        (add-points tx-sender u15)
        (ok true)
    )
)

(define-public (rate-session (session-id uint) (rating uint))
    (let ((session (unwrap! (map-get? sessions session-id) ERR-NOT-FOUND)))
        (asserts! (is-participant session-id tx-sender) ERR-UNAUTHORIZED)
        (asserts! (<= rating MAX-RATING) ERR-INVALID-RATING)
        (map-set session-ratings {session-id: session-id, user: tx-sender} rating)
        (add-points tx-sender u2)
        (ok true)
    )
)

;; Private functions
(define-private (add-points (user principal) (points uint))
    (let ((current-points (default-to u0 (map-get? user-points user))))
        (map-set user-points user (+ current-points points))
    )
)

(define-private (is-participant (session-id uint) (user principal))
    (let ((session (unwrap! (map-get? sessions session-id) false)))
        (is-some (index-of (get participants session) user))
    )
)

;; Read-only functions
(define-read-only (get-session (session-id uint))
    (ok (map-get? sessions session-id))
)

(define-read-only (get-user-points (user principal))
    (ok (default-to u0 (map-get? user-points user)))
)

(define-read-only (get-session-rating (session-id uint) (user principal))
    (ok (map-get? session-ratings {session-id: session-id, user: user}))
)
