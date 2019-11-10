
const expect = require('chai').expect;

describe("Hello World App", () => {

    describe("Tests", () => {

        it("should just test", () => {
            expect("Hello World").to.not.be.empty;

            // uncomment this to make the test fail:
            // expect("Hello World").to.be.empty;
        });

    });

});
