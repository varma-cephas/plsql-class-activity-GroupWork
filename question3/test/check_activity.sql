-- Attempt 1 (Count = 1)
INSERT INTO LOGIN_AUDIT (username, status, ip_address) VALUES ('user_a', 'FAILED', '192.168.1.1');
-- Attempt 2 (Count = 2)
INSERT INTO LOGIN_AUDIT (username, status, ip_address) VALUES ('user_a', 'FAILED', '192.168.1.1');
COMMIT;

-- Attempt 3 (Count = 3) -> Trigger fires, inserts into SECURITY_ALERTS
INSERT INTO LOGIN_AUDIT (username, status, ip_address) VALUES ('user_a', 'FAILED', '192.168.1.1');
COMMIT;

-- Verify the Alert:
SELECT username, failed_attempts_count, alert_message FROM SECURITY_ALERTS;